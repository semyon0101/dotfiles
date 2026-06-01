use serde_json::{Map, Value};
use signal_hook::{consts::SIGUSR1, iterator::Signals};
use std::collections::BTreeMap;
use std::env;
use std::fs;
use std::path::PathBuf;
use std::sync::{atomic::{AtomicBool, Ordering}, Arc};
use std::thread;
use std::time::Duration;

// === НАСТРОЙКИ СИСТЕМЫ ===
const SENSOR_RAW: &str = "/sys/bus/iio/devices/iio:device1/in_illuminance_raw";
const SENSOR_SCALE: &str = "/sys/bus/iio/devices/iio:device1/in_illuminance_scale";
const BL_VAL: &str = "/sys/class/backlight/intel_backlight/brightness";
const BL_MAX: &str = "/sys/class/backlight/intel_backlight/max_brightness";

// === ПАРАМЕТРЫ ЛОГИКИ И ПОРОГИ ===
const POLL_INTERVAL: Duration = Duration::from_secs(2);
const ANIMATION_DURATION_MS: u64 = 500; 
const ANIMATION_MAX_STEPS: u32 = 50;    

const LUX_BUCKET_SIZE: f32 = 20.0; 
const BRIGHTNESS_CHANGE_THRESHOLD: f32 = 0.03; 
const LUX_NORM: f64 = 1000.0; 

// === СТРУКТУРА ХРАНЕНИЯ ===
struct AppConfig {
    points: BTreeMap<u32, f32>,
    coeffs: [f64; 3], // Теперь храним только a, b, c
}

// === ФУНКЦИИ ВВОДА/ВЫВОДА ===
fn read_f32(path: &str) -> Option<f32> {
    fs::read_to_string(path).ok()?.trim().parse().ok()
}

fn read_u32(path: &str) -> Option<u32> {
    fs::read_to_string(path).ok()?.trim().parse().ok()
}

fn get_config_path() -> PathBuf {
    let home = env::var("HOME").unwrap_or_else(|_| "/root".to_string());
    PathBuf::from(format!("{}/.config/als-daemon/config.json", home))
}

fn load_config() -> AppConfig {
    let path = get_config_path();
    let mut config = AppConfig {
        points: BTreeMap::new(),
        coeffs: [0.5, 0.0, 0.0], // Базовые a, b, c
    };

    if let Ok(data) = fs::read_to_string(&path) {
        if let Ok(v) = serde_json::from_str::<Value>(&data) {
            if let Some(coeffs_arr) = v.get("coeffs").and_then(|v| v.as_array()) {
                for i in 0..3 {
                    if let Some(num) = coeffs_arr.get(i).and_then(|n| n.as_f64()) {
                        config.coeffs[i] = num;
                    }
                }
            }
            if let Some(points_map) = v.get("points").and_then(|v| v.as_object()) {
                for (k, val) in points_map {
                    if let (Ok(key), Some(num)) = (k.parse::<u32>(), val.as_f64()) {
                        config.points.insert(key, num as f32);
                    }
                }
            }
        }
    } else {
        if let Some(parent) = path.parent() {
            let _ = fs::create_dir_all(parent);
        }
    }
    config
}

fn save_config(config: &AppConfig) {
    let mut map = Map::new();
    
    let mut points_map = Map::new();
    for (k, v) in &config.points {
        points_map.insert(k.to_string(), Value::from(*v as f64));
    }
    map.insert("points".to_string(), Value::Object(points_map));
    
    let coeffs_vec: Vec<Value> = config.coeffs.iter().map(|&c| Value::from(c)).collect();
    map.insert("coeffs".to_string(), Value::Array(coeffs_vec));

    if let Ok(json_str) = serde_json::to_string_pretty(&Value::Object(map)) {
        let _ = fs::write(get_config_path(), json_str);
    }
}

// === МАТЕМАТИЧЕСКОЕ ЯДРО (МНК для квадратичной функции) ===
fn solve_matrix(m: &mut [[f64; 3]; 3], v: &mut [f64; 3], n: usize) -> Option<[f64; 3]> {
    for i in 0..n {
        let mut max_row = i;
        for k in i + 1..n {
            if m[k][i].abs() > m[max_row][i].abs() { max_row = k; }
        }
        if m[max_row][i].abs() < 1e-9 { return None; }
        
        m.swap(i, max_row);
        v.swap(i, max_row);

        for k in i + 1..n {
            let factor = m[k][i] / m[i][i];
            for j in i..n { m[k][j] -= factor * m[i][j]; }
            v[k] -= factor * v[i];
        }
    }

    let mut ans = [0.0f64; 3];
    for i in (0..n).rev() {
        let mut sum = 0.0;
        for j in i + 1..n { sum += m[i][j] * ans[j]; }
        ans[i] = (v[i] - sum) / m[i][i];
    }
    Some(ans)
}

fn get_coefficients(points: &BTreeMap<u32, f32>) -> [f64; 3] {
    let n = points.len();
    if n == 0 { return [0.5, 0.0, 0.0]; } 
    if n == 1 { return [*points.values().next().unwrap() as f64, 0.0, 0.0]; }

    // Ограничиваем степень полинома: максимум 2 (квадратичная функция)
    let degree = std::cmp::min(2, n - 1);
    let vars = degree + 1;

    let mut m = [[0.0f64; 3]; 3];
    let mut v = [0.0f64; 3];

    for (&lux, &y) in points.iter() {
        let x = (lux as f64) / LUX_NORM;
        let y = y as f64;
        
        // Для квадратичной функции максимальная степень x_p будет x^4 (2 * vars),
        // поэтому массива размером 8 хватит с запасом.
        let mut x_p = [1.0f64; 8]; 
        for i in 1..=vars * 2 { x_p[i] = x_p[i-1] * x; }

        for r in 0..vars {
            for c in 0..vars { m[r][c] += x_p[r + c]; }
            v[r] += y * x_p[r];
        }
    }

    let mut a = [0.0f64; 3];
    if let Some(ans) = solve_matrix(&mut m, &mut v, vars) {
        for i in 0..vars { a[i] = ans[i]; }
    } else {
        a[0] = *points.values().next().unwrap() as f64;
    }
    a
}

// === УМНАЯ АНИМАЦИЯ ===
fn animate_brightness(start: u32, end: u32) {
    if start == end { return; }
    
    let diff_abs = (end as i32 - start as i32).abs() as u32;
    let steps = std::cmp::min(diff_abs, ANIMATION_MAX_STEPS); 
    
    if steps == 0 { return; }
    
    let delay = Duration::from_millis(ANIMATION_DURATION_MS / steps as u64);
    let diff = end as f32 - start as f32;

    for i in 1..=steps {
        let current = (start as f32 + (diff * (i as f32 / steps as f32))).round() as u32;
        let _ = fs::write(BL_VAL, current.to_string());
        thread::sleep(delay);
    }
}

// === ГЛАВНЫЙ ЦИКЛ ===
fn main() {
    let is_paused = Arc::new(AtomicBool::new(false));
    let is_paused_clone = Arc::clone(&is_paused);
    
    thread::spawn(move || {
        let mut signals = Signals::new(&[SIGUSR1]).expect("Failed to create signals iterator");
        for _ in signals.forever() {
            let current = is_paused_clone.load(Ordering::Relaxed);
            let new_state = !current;
            is_paused_clone.store(new_state, Ordering::Relaxed);
            
            if new_state {
                println!("[SIGUSR1] ALS Daemon: PAUSED (Auto-brightness disabled)");
            } else {
                println!("[SIGUSR1] ALS Daemon: RESUMED (Auto-brightness enabled)");
            }
        }
    });

    let mut config = load_config();
    let max_bl = read_u32(BL_MAX).expect("Failed to read max_brightness");
    let mut last_set_bl = read_u32(BL_VAL).unwrap_or(0);

    if config.coeffs == [0.5, 0.0, 0.0] && !config.points.is_empty() {
        config.coeffs = get_coefficients(&config.points);
        save_config(&config);
    }

    println!("ALS Adaptive Daemon started. PID: {}", std::process::id());

    loop {
        thread::sleep(POLL_INTERVAL);

        if is_paused.load(Ordering::Relaxed) { continue; }

        let lux = match (read_f32(SENSOR_RAW), read_f32(SENSOR_SCALE)) {
            (Some(r), Some(s)) => r * s,
            _ => continue,
        };

        let actual_bl = match read_u32(BL_VAL) {
            Some(b) => b,
            None => continue,
        };

        let bucket = (lux / LUX_BUCKET_SIZE).round() as u32 * LUX_BUCKET_SIZE as u32;

        if (actual_bl as f32 - last_set_bl as f32).abs() > (max_bl as f32 * 0.02) {
            let new_percent = actual_bl as f32 / max_bl as f32;
            
            config.points.insert(bucket, new_percent);
            config.coeffs = get_coefficients(&config.points);
            save_config(&config);
            
            println!("\n[LEARNED] Bucket {} lux set to {:.1}%.", bucket, new_percent * 100.0);
            println!("[COEFFS] a={:.4}, b={:.4}, c={:.4}", 
                     config.coeffs[0], config.coeffs[1], config.coeffs[2]);
            
            last_set_bl = actual_bl;
            continue;
        }

        let c = config.coeffs;
        let x = (lux as f64) / LUX_NORM;
        
        // Вычисляем y = a + bx + cx^2
        let mut target_percent = c[0] + c[1]*x + c[2]*x*x;
        
        target_percent = target_percent.clamp(0.01, 1.0);
        let target_bl = (max_bl as f64 * target_percent) as u32;

        let diff_percent = (target_bl as f32 - actual_bl as f32).abs() / max_bl as f32;

        if diff_percent > BRIGHTNESS_CHANGE_THRESHOLD {
            let actual_pct = (actual_bl as f32 / max_bl as f32) * 100.0;
            let target_pct = target_percent * 100.0;
            
            println!("[AUTO] Lux: {:.1} | Diff: {:.1}% (> {:.1}%) | Brightness: {:.1}% -> {:.1}%", 
                     lux, 
                     diff_percent * 100.0, 
                     BRIGHTNESS_CHANGE_THRESHOLD * 100.0, 
                     actual_pct, 
                     target_pct);

            animate_brightness(actual_bl, target_bl);
            last_set_bl = target_bl;
        }
    }
}

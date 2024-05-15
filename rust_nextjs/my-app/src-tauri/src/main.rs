// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use ark_bn254::Bn254;
use ark_circom::CircomBuilder;
use ark_circom::CircomConfig;
use ark_groth16::Groth16;
use ark_snark::SNARK;
use rand::Rng;

fn main() {
  tauri::Builder::default()
    .invoke_handler(tauri::generate_handler![greet])
    .run(tauri::generate_context!())
    .expect("error while running tauri application");
    
}

//#[tauri::command]
//fn greet(name: &str) -> String {
//   format!("Hello, {}!", name)
//}

#[tauri::command]
fn greet(name: &str) -> String {
   format!("Hello, {}!", name)
}
#[macro_use]
mod cli;

use std::fs::File;
use std::io::{BufReader, Read};
use std::path::Path;

use crate::cli::{Commands, Options};

use clap::Parser;
use interpreter::interpret;

pub fn main() {
    let options = Options::parse();

    match options.command {
        Commands::Interpret { filepath } => {
            let input = get_input(filepath.clone());
            match input {
                Ok(input) => interpret(Path::new(&filepath), input),
                Err(e) => eprintln!("{}", e),
            }
        }
    }
}

fn get_input(filepath: String) -> Result<String, String> {
    match filepath.as_str() {
        "-" => {
            let mut buffer = String::new();
            std::io::stdin()
                .read_to_string(&mut buffer)
                .expect("Failed to read from stdin");
            Ok(buffer)
        }
        _ => {
            let filename = Path::new(&filepath);
            let file = File::open(filename)
                .map_err(|_| format!("Failed to open file: {}", filename.display()))?;
            let mut reader = BufReader::new(file);
            let mut contents = String::new();
            reader
                .read_to_string(&mut contents)
                .map_err(|_| format!("Failed to read from file: {}", filename.display()))?;
            Ok(contents)
        }
    }
}

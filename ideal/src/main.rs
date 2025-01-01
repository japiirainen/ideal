#[macro_use]
mod cli;

use crate::cli::{Commands, Options};

use clap::Parser;

pub fn main() {
    let options = Options::parse();

    match options.command {
        Commands::Interpret { filepath } => {
            println!("interpret: {}", filepath);
        }
    }
}

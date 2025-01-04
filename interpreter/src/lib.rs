use std::path::Path;

pub fn interpret(filename: &Path, contents: String) {
    println!("Interpreting file: {:?}", filename);
    println!("Contents: {}", contents);
}

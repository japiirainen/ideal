use std::path::Path;

use web_sys::window;

fn main() {
    console_error_panic_hook::set_once();
    let document = window()
        .and_then(|win| win.document())
        .expect("Could not access the document");
    let body = document.body().expect("Could not access document.body");

    match interpreter::interpret(Path::new("<user>"), "1 + 2".to_string()) {
        Ok(_) => {}
        Err(e) => {
            let text_node = document.create_text_node(&format!("{}", e.display()));
            body.append_child(text_node.as_ref())
                .expect("Failed to append text");
            body.append_child(text_node.as_ref())
                .expect("Failed to append text");
        }
    }
}

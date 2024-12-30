use web_sys::window;

fn main() {
    console_error_panic_hook::set_once();
    let document = window()
        .and_then(|win| win.document())
        .expect("Could not access the document");
    let body = document.body().expect("Could not access document.body");
    let text_node = document.create_text_node(&format!("`ideal`: {}", interpreter::add(2, 5)));
    body.append_child(text_node.as_ref())
        .expect("Failed to append text");
}

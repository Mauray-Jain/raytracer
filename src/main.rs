fn main() {
    const IMAGE_WIDTH : i32 = 256;
    const IMAGE_HEIGHT: i32 = 256;

    // Render
    println!("P3");
    println!("{} {}", IMAGE_WIDTH, IMAGE_HEIGHT);
    println!("255");

    for j in 0..IMAGE_WIDTH {
        for i in 0..IMAGE_HEIGHT {
            let r = (i as f64) / ((IMAGE_WIDTH  - 1) as f64);
            let g = (j as f64) / ((IMAGE_HEIGHT - 1) as f64);
            let b = 0.0;

            let r = (r * 255.99) as i32;
            let g = (g * 255.99) as i32;
            let b = (b * 255.99) as i32;

            println!("{} {} {}", r, g, b);
        }
    }
}

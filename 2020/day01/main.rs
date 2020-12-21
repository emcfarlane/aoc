use std::collections::HashMap;
use std::env;
use std::fs;
use std::io::{self, BufRead};

const TARGET: i32 = 2020;

fn main() -> Result<(), std::io::Error> {
    let args: Vec<String> = env::args().collect();

    let filename = &args[1];
    let file = fs::File::open(filename)?;
    let lines = io::BufReader::new(file).lines();

    let mut two_pair = None;
    let mut three_pair = None;
    let mut numbers = HashMap::new();

    for line in lines {
        let s = line?;
        let a: i32 = s.parse().unwrap();
        let b = TARGET - a;

        // Two Pair
        if let Some(_) = numbers.get(&b) {
            println!("{} + {} = {}", a, b, a + b);
            println!("{} * {} = {}", a, b, a * b);
            two_pair = Some(a * b);
        }

        // Three Pair
        for (x, &count) in numbers.iter() {
            let c = b - x;
            if c < 0 || (c == b && (count < 2)) {
                continue;
            }
            if let Some(_) = numbers.get(&c) {
                println!("{} + {} + {} = {}", a, x, c, a + x + c);
                println!("{} * {} * {} = {}", a, x, c, a * x * c);
                three_pair = Some(a * x * c);
            }
        }

        let count = numbers.entry(a).or_insert(0);
        *count += 1;
    }

    match two_pair {
        Some(m) => println!("success two pair {}", m),
        None => println!("failed two pair"),
    };
    match three_pair {
        Some(m) => println!("success three pair {}", m),
        None => println!("failed three pair"),
    };
    Ok(())
}

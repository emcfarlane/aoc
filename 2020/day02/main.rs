use std::env;
use std::fs;
use std::io::{self, BufRead};

fn main() -> Result<(), std::io::Error> {
    let args: Vec<String> = env::args().collect();

    let filename = &args[1];
    let file = fs::File::open(filename)?;
    let lines = io::BufReader::new(file).lines();

    let mut part_one: usize = 0;
    let mut part_two: usize = 0;

    for line in lines {
        let s = line?;

        // "{min_count}-{max_count} {char}: {password}"

        let mut ws_split = s.split_whitespace();

        let mut counts = ws_split.next().unwrap().split('-');
        let min_count: usize = counts.next().unwrap().parse().unwrap();
        let max_count: usize = counts.next().unwrap().parse().unwrap();

        let char = ws_split.next().unwrap().chars().next().unwrap();

        let password = ws_split.next().unwrap();
        //println!("{}-{} {}: {}", min_count, max_count, char, password);

        let count = password.matches(char).count();
        if min_count <= count && count <= max_count {
            part_one += 1;
        }

        let mut chars = password.chars();
        let first = chars.nth(min_count - 1);
        let second = chars.nth(max_count - min_count - 1);

        let mut valid = false;
        if let Some(c) = first {
            valid ^= c == char
        }
        if let Some(c) = second {
            valid ^= c == char
        }
        if valid {
            part_two += 1;
        }
        //println!("{:?} {:?} {}", first, second, valid);
    }
    println!("part one valid {}", part_one);
    println!("part two valid {}", part_two);
    Ok(())
}

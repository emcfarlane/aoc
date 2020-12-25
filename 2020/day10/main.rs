use std::collections::HashMap;
use std::env;
use std::fs;
use std::io::{self, BufRead};

fn count_arrangements(joltages: Vec<u32>) -> u64 {
    let mut sums: Vec<u64> = vec![1; joltages.len()];

    for i in (0..joltages.len() - 1).rev() {
        let mut sum: u64 = 0;
        for j in (i + 1)..joltages.len() {
            if joltages[j] - joltages[i] > 3 {
                break;
            }
            sum += sums[j];
        }
        sums[i] = sum;
    }
    sums[0]
}

fn main() -> Result<(), std::io::Error> {
    let args: Vec<String> = env::args().collect();

    let filename = &args[1];
    let file = fs::File::open(filename)?;
    let lines = io::BufReader::new(file).lines();

    let mut joltages = Vec::new();
    joltages.push(0);

    for line in lines {
        let s = line?;

        let jolt: u32 = s.parse().unwrap();
        joltages.push(jolt);
    }
    joltages.sort();
    joltages.push(joltages.last().unwrap() + 3 as u32);

    let mut ones: u32 = 0;
    let mut threes: u32 = 0;

    for i in 1..joltages.len() {
        match joltages[i] - joltages[i - 1] {
            1 => ones += 1,
            3 => threes += 1,
            _ => (),
        }
    }
    println!(
        "ones {}, threes {}, product {}",
        ones,
        threes,
        ones * threes
    );
    println!("arrangements {}", count_arrangements(joltages));
    Ok(())
}

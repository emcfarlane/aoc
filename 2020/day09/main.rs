use std::cmp::{max, min};
use std::collections::HashMap;
use std::env;
use std::fs;
use std::io::{self, BufRead};

fn find_continous_sum(list: Vec<u32>, total: u32) -> Option<u32> {
    for i in 0..(list.len() - 1) {
        let mut sum = list[i];
        let mut min_num = list[i];
        let mut max_num = list[i];
        for j in (i + 1)..list.len() {
            sum += list[j];
            if sum > total {
                break;
            }
            min_num = min(list[j], min_num);
            max_num = max(list[j], max_num);
            if sum == total {
                return Some(min_num + max_num);
            }
        }
    }
    None
}

fn main() -> Result<(), std::io::Error> {
    let args: Vec<String> = env::args().collect();

    let filename = &args[1];
    let file = fs::File::open(filename)?;
    let lines = io::BufReader::new(file).lines();

    let preamble_length: usize = 25;
    let mut numbers: [u32; 25] = [0; 25];
    let mut lookup = HashMap::new();
    let mut part1 = None;
    let mut list = Vec::new();

    for (idx, line) in lines.enumerate() {
        let s = line?;

        let c: u32 = s.parse().unwrap();
        list.push(c);

        // Check we have a valid sum: a + b = c.
        if idx >= preamble_length {
            let ok = numbers.iter().any(|a| {
                if *a > c {
                    return false;
                }
                let b = c - a;
                match lookup.get(&b) {
                    Some(_) => true,
                    None => false,
                }
            });

            if !ok {
                println!("missing {}: {}", idx, c);
                part1 = Some(c);
                break;
            }
        }

        let i = idx % preamble_length;
        if idx >= preamble_length {
            let x = numbers[i];
            let count = lookup.entry(x).or_insert(0);
            *count -= 1;
            if *count == 0 {
                lookup.remove(&x);
            }
        }
        numbers[i] = c;
        let count = lookup.entry(c).or_insert(0);
        *count += 1;
    }
    let part2 = find_continous_sum(list, part1.unwrap());
    println!("min/max sum: {:?}", part2.unwrap());
    Ok(())
}

use std::collections::HashMap;
use std::env;
use std::fs;
use std::io::{self, BufRead};

fn main() -> Result<(), std::io::Error> {
    let args: Vec<String> = env::args().collect();

    let filename = &args[1];
    let file = fs::File::open(filename)?;
    let lines = io::BufReader::new(file).lines();

    let mut ones_mask: u64 = 0;
    let mut zeros_mask: u64 = 0;
    let mut floats = Vec::new();
    let mut memory: HashMap<u64, u64> = HashMap::new();
    let mut address: HashMap<u64, u64> = HashMap::new();
    for line in lines {
        let s = line?;
        let mut words = s.split_whitespace();

        let op = words.next().unwrap();
        words.next().unwrap(); // =
        let val = words.next().unwrap();

        if op == "mask" {
            zeros_mask = 0;
            ones_mask = 0;
            floats.clear();
            for (i, c) in val.chars().enumerate() {
                let shift = 35 - i;
                if c == 'X' {
                    zeros_mask |= 1 << (shift);
                    floats.push(shift);
                } else if c == '0' {
                    //zeros_mask |= 0 << (shift);
                } else if c == '1' {
                    zeros_mask |= 1 << (shift);
                    ones_mask |= 1 << (shift);
                }
            }
        } else {
            let pos = op
                .strip_prefix("mem[")
                .unwrap()
                .strip_suffix("]")
                .unwrap()
                .parse::<u64>()
                .unwrap();

            let x = val.parse::<u64>().unwrap();
            memory.insert(pos, (x & zeros_mask) | ones_mask);

            let pos = pos | ones_mask;
            let mut store = Vec::new();
            float_addresses(pos, &floats, &mut store);
            for pos in store.iter() {
                address.insert(*pos, x);
            }
        }
    }
    //println!("map {:?}", memory);
    println!("memory: {}", memory.values().sum::<u64>());
    //println!("map {:?}", address);
    println!("address: {}", address.values().sum::<u64>());
    Ok(())
}

fn float_addresses(pos: u64, floats: &[usize], store: &mut Vec<u64>) {
    store.push(pos);
    if floats.is_empty() {
        return;
    }
    let f = floats[0];
    let len = floats.len();
    float_addresses(pos | 1 << f, &floats[1..len], store); // set
    float_addresses(pos & !(1 << f), &floats[1..len], store); // clear
}

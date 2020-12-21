use std::collections::HashSet;
use std::env;
use std::fs;
use std::io::{self, BufRead};

fn main() -> Result<(), std::io::Error> {
    let args: Vec<String> = env::args().collect();

    let filename = &args[1];
    let file = fs::File::open(filename)?;
    let lines = io::BufReader::new(file).lines();

    let mut new_group = true;
    let mut anyone: usize = 0;
    let mut everyone: usize = 0;
    let mut answers_anyone = HashSet::new();
    let mut answers_everyone = HashSet::new();

    for line in lines {
        let s = line?;

        // Empty line.
        if s.len() == 0 {
            anyone += answers_anyone.len();
            everyone += answers_everyone.len();
            answers_anyone.clear();
            answers_everyone.clear();
            new_group = true;
            continue;
        }

        let mut answers = HashSet::new();

        for ch in s.chars() {
            answers_anyone.insert(ch);
            if new_group {
                answers_everyone.insert(ch);
            } else {
                answers.insert(ch);
            }
        }

        if !new_group {
            answers_everyone = answers_everyone.intersection(&answers).copied().collect();
        }
        new_group = false;
    }
    anyone += answers_anyone.len();
    everyone += answers_everyone.len();

    println!("anyone {}", anyone);
    println!("everyone {}", everyone);
    Ok(())
}

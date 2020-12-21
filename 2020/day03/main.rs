use std::env;
use std::fs;
use std::io::{self, BufRead};

struct Slope {
    right: usize,
    down: usize,
}

fn main() -> Result<(), std::io::Error> {
    let args: Vec<String> = env::args().collect();

    let filename = &args[1];
    let file = fs::File::open(filename)?;
    let lines = io::BufReader::new(file).lines();

    let slopes: [Slope; 5] = [
        Slope { right: 1, down: 1 },
        Slope { right: 3, down: 1 },
        Slope { right: 5, down: 1 },
        Slope { right: 7, down: 1 },
        Slope { right: 1, down: 2 },
    ];
    let mut indexes = [0; 5];
    let mut counts = [0; 5];

    for (i, line) in lines.enumerate() {
        let s = line?;
        let chars: Vec<char> = s.chars().collect();
        let count = chars.len();

        for j in 0..5 {
            let slope = &slopes[j];
            if i % slope.down != 0 {
                continue;
            }

            let index = indexes[j] % count;
            if chars[index] == '#' {
                counts[j] += 1;
            }

            indexes[j] += slope.right;
        }
    }
    println!(
        "trees: {:?} product: {}",
        counts,
        counts.iter().product::<usize>()
    );
    Ok(())
}

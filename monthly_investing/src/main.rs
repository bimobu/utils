use clap::Parser;
use num_format::{Locale, ToFormattedString};

// TODO add tests!

/// Simple program to calculate the expected return when investing a fixed amount every month
#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct Args {
    /// Initial balance
    #[arg(short, long, default_value_t = 5000.0)]
    balance: f64,

    /// Expected annual return in percent
    #[arg(short, long, default_value_t = 8)]
    roi: u8,

    /// Monthly invested amount
    #[arg(short, long, default_value_t = 500.0)]
    monthly_investment: f64,

    /// Number of years to wait
    #[arg(short, long, default_value_t = 10)]
    years: i64,
}

fn main() {
    let args = Args::parse();

    let Args {
        balance: initial_balance,
        roi,
        monthly_investment,
        years,
    } = args;

    let annual_return = 1.0 + (roi as f64 / 100.0);
    let monthly_return = annual_return.powf(1.0 / 12.0);
    let months = years * 12;
    let mut balance = initial_balance;

    for _ in 0..months {
        balance *= monthly_return;
        balance += monthly_investment;
    }

    let balance_string = (balance.round() as i64).to_formatted_string(&Locale::en);
    let invested_amount = (initial_balance + months as f64 * monthly_investment).round();
    let invested_amount_string = (invested_amount as i64).to_formatted_string(&Locale::en);
    let gained_interest = (balance - invested_amount).round();
    let gained_interest_string = (gained_interest as i64).to_formatted_string(&Locale::en);

    println!("Initial balance: {initial_balance}");
    println!("Monthly investment: {monthly_investment}");
    println!("Annual return: {roi}%");
    println!("Waiting time: {years} years");
    println!("Final balance: {balance_string}");
    println!("Overall invested amount (including initial balance): {invested_amount_string}");
    println!("Amount gained in interest: {gained_interest_string}");
}

use clap::Parser;

#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct Args {
    /// The plate outer diameter in cm
    #[arg(short, long, default_value_t = 25.0)]
    outer_diameter: f64,
    /// The inner diameter (diameter of the hole) in cm
    #[arg(short, long, default_value_t = 3.0)]
    inner_diameter: f64,
    /// The width of the plate in cm
    #[arg(short, long, default_value_t = 8.0)]
    width: f64,
    /// The density of the concrete in g/cm^3
    #[arg(short, long, default_value_t = 2.0)]
    density: f64,
}

fn main() {
    let Args {
        outer_diameter,
        inner_diameter,
        width,
        density,
    } = Args::parse();

    let volume = get_volume(inner_diameter, outer_diameter, width);
    let mass = volume * density / 1000.0;
    let mass_string = format!("{:.3}", mass);
    println!("The mass of the plate is {}kg", mass_string);
}

fn get_area(diameter: f64) -> f64 {
    let radius = diameter / 2.0;
    (radius).powi(2) * std::f64::consts::PI
}

fn get_volume(inner_diameter: f64, outer_diameter: f64, width: f64) -> f64 {
    let inner_area = get_area(inner_diameter);
    let outer_area = get_area(outer_diameter);
    (outer_area - inner_area) * width
}

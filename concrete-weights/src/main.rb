# frozen_string_literal: true

def get_area(radius)
  (radius**2) * Math::PI
end

def get_volume(outer_diameter, inner_diameter, width)
  outer_radius = outer_diameter / 2
  inner_radius = inner_diameter / 2
  (get_area(outer_radius) - get_area(inner_radius)) * width
end

def get_weight(outer_diameter, inner_diameter, width, density)
  vol = get_volume(outer_diameter, inner_diameter, width)
  vol * density
end

def get_weight_string(weight)
  "#{weight.round.to_f / 1000}kg"
end

def get_console_input(default_value)
  value = gets.chomp.sub(",", ".").to_f
  value = default_value if value.zero?
  value
end

puts "This util lets you calculate the weight of a concrete weight plate with certain dimensions.\n\n"

puts "What is the diameter in cm? (default 25)"
outer_diameter = get_console_input 25

puts "What is the diameter of the hole in cm? (default 3)"
inner_diameter = get_console_input 3

puts "What is the width in cm? (default 3)"
width = get_console_input 3

puts "What is the density of the concrete in g/cm^3? (default 2)" # typically 1,8 - 2,4 g/cm3
density = get_console_input 2

weight = get_weight(outer_diameter, inner_diameter, width, density)
puts "The weight of the plate is #{get_weight_string(weight)}."

class_name NumberValue

var value: float = 0

func increase_value(val: float):
    value += val

func set_value(new_value: float):
    value = new_value

func get_value():
    return value

func get_decimal_number_format_value(division_base: float):
    var before_decimal = floor(value / division_base)

    var after_decimal = int(value) % int(division_base)
    after_decimal = floor(after_decimal / (division_base / 10))

    if after_decimal == 0:
        return str(before_decimal)
    else:
        return str(before_decimal) + "." + str(after_decimal)

func show():
    # Smaller than thousand, show ther raw value
    if value < 1e3:
        return str(value)
    
    # Thousands
    elif value < 1e6:
        return get_decimal_number_format_value(1e3) + "k"
    
    # Millions
    elif value < 1e9:
        return get_decimal_number_format_value(1e6) + " million"
    
    # Billion
    elif value < 1e12:
        return get_decimal_number_format_value(1e9) + " billion"
    
    # Trillion
    elif value < 1e15:
        return get_decimal_number_format_value(1e12) + " trillion"
    
    # Quadrillion 
    elif value < 1e18:
        return get_decimal_number_format_value(1e15) + " quadrillion"
    
    # Quintillion 
    elif value < 1e21:
        return get_decimal_number_format_value(1e18) + " quintillion"
    
    # Sextillion 
    elif value < 1e24:
        return get_decimal_number_format_value(1e21) + " sextillion"
    
    # Septillion  
    elif value < 1e27:
        return get_decimal_number_format_value(1e24) + " septillion"
    
    # Octillion  
    elif value < 1e30:
        return get_decimal_number_format_value(1e27) + " octillion"
    
    # Nonillion  
    elif value < 1e33:
        return get_decimal_number_format_value(1e30) + " nonillion"
    
    # Decillion   
    elif value < 1e36:
        return get_decimal_number_format_value(1e33) + " decillion"
    
    # Undecillion   
    elif value < 1e39:
        return get_decimal_number_format_value(1e36) + " undecillion"
    
    # Duodecillion
    else:
        return get_decimal_number_format_value(1e39) + " duodecillion"
def format_number(value):
    """Format a number with thousand separators"""
    try:
        return "{:,}".format(int(value))
    except (ValueError, TypeError):
        return value
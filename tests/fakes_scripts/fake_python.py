def somme(a, b):
    if a > 0 and b > 0:
        return a + b  # L'indentation remplace les {}
    else:
        return "Les nombres doivent être positifs" 

print("Ceci n'est pas une fonction")

def somme2(a, b):
    return somme(a, b)   

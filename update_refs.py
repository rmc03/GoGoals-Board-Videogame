import os
import shutil

REPLACEMENTS = {
    "res://GameData.gd": "res://autoloads/GameData.gd",
    "res://RecordsManager.gd": "res://autoloads/RecordsManager.gd",
    "res://AudioManager.gd": "res://autoloads/AudioManager.gd",
    "res://MainBoard.gd": "res://scripts/MainBoard.gd",
    "res://IconoFlotante.gd": "res://scripts/IconoFlotante.gd",
    "res://pantalla_de_juego.tscn": "res://scenes/pantalla_de_juego.tscn",
    "res://FichaJugador.tscn": "res://scenes/FichaJugador.tscn",
    "res://MenuPrincipal.gd": "res://ui/MenuPrincipal.gd",
    "res://MenuPrincipal.tscn": "res://ui/MenuPrincipal.tscn",
    "res://ComoJugar.gd": "res://ui/ComoJugar.gd",
    "res://ComoJugar.tscn": "res://ui/ComoJugar.tscn",
    "res://EndGameMenu.gd": "res://ui/EndGameMenu.gd",
    "res://EndGameMenu.tscn": "res://ui/EndGameMenu.tscn",
    "res://Audio/": "res://Assets/audio/",
    "res://Fonts/": "res://Assets/Fonts/",
    "res://Imágenes a Añadir/": "res://Assets/images/",
    "res://hexa_128x128_93.png": "res://Assets/images/hexa_128x128_93.png",
    "res://icon.svg": "res://Assets/images/icon.svg"
}

def update_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    new_content = content
    for old, new in REPLACEMENTS.items():
        new_content = new_content.replace(old, new)
        
    if new_content != content:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated: {filepath}")

def move_leftovers():
    files_to_move = [
        "hexa_128x128_93.png",
        "hexa_128x128_93.png.import",
        "icon.svg",
        "icon.svg.import"
    ]
    for file in files_to_move:
        if os.path.exists(file):
            shutil.move(file, os.path.join("Assets", "images", file))
            print(f"Moved {file}")

if __name__ == "__main__":
    move_leftovers()
    for root, dirs, files in os.walk("."):
        if ".git" in root or ".godot" in root:
            continue
        for file in files:
            if file.endswith((".gd", ".tscn", ".tres", ".godot")):
                update_file(os.path.join(root, file))
    print("Done.")

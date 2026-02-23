import pandas as pd
import requests
import json
import os

def update_prices():
    # URL du flux RNM (Prix détail Fruits et Légumes)
    URL_RNM = "https://www.data.gouv.fr/fr/datasets/r/cb2d0f50-4890-449e-8733-68d1976007e0"
    
    try:
        # 1. Récupération du CSV
        print("Téléchargement des données...")
        df = pd.read_csv(URL_RNM, sep=';', encoding='utf-8')
        
        # 2. Nettoyage (Exemple basé sur les colonnes types du RNM)
        # On garde les colonnes : Produit, Variété, Prix, Unité
        # On convertit le prix en float (remplacement de la virgule par un point)
        df['prix'] = df['prix'].toString().str.replace(',', '.').astype(float)
        
        # On crée un dictionnaire : "pomme gala": 2.50
        prices_dict = {}
        for _, row in df.iterrows():
            name = f"{row['produit']} {row['variete']}".lower().strip()
            prices_dict[name] = {
                "p": row['prix'],
                "u": row['unite']
            }
        
        # 3. Sauvegarde du fichier JSON
        with open('market_prices.json', 'w', encoding='utf-8') as f:
            json.dump(prices_dict, f, ensure_ascii=False)
        
        print("Fichier market_prices.json mis à jour !")
    except Exception as e:
        print(f"Erreur : {e}")

if __name__ == "__main__":
    update_prices()
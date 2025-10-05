# Objetivos do Jogo

## Visão Geral
Este documento descreve os objetivos para o nosso jogo, uma ferramenta visual para projetar e avaliar layouts de habitats espaciais, em resposta ao desafio "Design a Space Habitat" da NASA Space Apps.

O objetivo principal é criar uma ferramenta acessível, educativa e divertida que permita aos usuários (de estudantes a profissionais) experimentar o design de habitats para missões na Lua, em Marte ou em trânsito.

---

## O Que Já Temos
A base do projeto já está bem encaminhada, o que nos dá uma ótima vantagem inicial:
- **Motor:** Projeto Godot funcional e configurado.
- **Sistema de Construção:** Scripts como `builder.gd` e `module_controller.gd` indicam que um sistema de construção modular já existe ou está em desenvolvimento.
- **Vasta Biblioteca de Assets:** Temos uma grande quantidade de modelos 3D para estruturas, móveis e partes de foguete em `/structures` e `/models`.
- **Cenas Iniciais:** `main.tscn` e `rocket.tscn` fornecem um ponto de partida para a cena principal e o habitat.
- **Lógica de Dados:** Scripts como `data_map.gd` e `data_structure.gd` sugerem que a lógica para gerenciar os dados do habitat já foi pensada.

---

## Objetivos para o MVP (Minimum Viable Product)
Para a primeira versão, nosso foco é entregar a experiência principal de forma simples, mas cativante.

**Feature 1: Construção da Estrutura Externa**
- O usuário deve ser capaz de montar um habitat cilíndrico básico usando os módulos de foguete existentes (`rocket_base_a`, `rocket_sides_a`, `rocket_top_a`).
- A construção deve ser intuitiva, talvez com um sistema de "snap" para encaixar as peças.

**Feature 2: Layout do Espaço Interno**
- Permitir que o usuário posicione objetos e móveis da biblioteca `/structures` dentro do habitat que ele montou.
- Implementar um sistema de grid ou de posicionamento livre com feedback visual claro (por exemplo, um highlight verde para local válido e vermelho para inválido).

**Feature 3: Interface de Usuário (UI) Mínima**
- Um menu simples para selecionar as peças da estrutura externa.
- Um catálogo visual para selecionar os móveis/objetos internos a serem posicionados.

**Feature 4: Câmera e Controles**
- Controles de câmera que permitam ao usuário orbitar, dar zoom e mover a visão para inspecionar o habitat por fora e navegar por dentro.

**Feature 5: Contexto e Engajamento (O Fator "Cativante")**
- Apresentar um "cenário de missão" simples no início. Ex: **"Sua missão: projetar um habitat para 2 astronautas em uma missão lunar de 30 dias."**
- Exibir um ou dois contadores básicos que reagem em tempo real, como **"Espaço Utilizado (%)"** ou **"Consumo de Energia (kW)"**. Isso introduz o conceito de restrições de forma simples e visual, sem a necessidade de regras complexas no MVP.

---

## Features Futuras (Pós-MVP)
Após o MVP, podemos expandir a ferramenta com base nos objetivos do desafio da NASA:
- **Sistema de Regras e Validação:** Verificar se o layout atende às necessidades da missão (área mínima para sono, separação de zonas de ruído, etc.) com feedback visual.
- **Diversidade de Habitats:** Adicionar outros tipos de estruturas, como habitats infláveis ou impressos em 3D na superfície.
- **Cenários de Missão Avançados:** Diferentes desafios com variações de tripulação, duração e destino (Lua, Marte).
- **Painel de Análise:** Fornecer dados quantitativos sobre o design (volume total, área por função, massa, etc.).
- **Compartilhamento de Designs:** Permitir que os usuários salvem e compartilhem suas criações.

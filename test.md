
<!--

Space ship mass: 28801 kg

- **Взлет (Launch):** `mass * gravity * 0,042 - 33` (округление вниз)
- **Посадка (Landing):** `mass * gravity * 0,033 - 42` (округление вниз)

- Земля (Earth): 9,807
- Луна (Moon): 1,62
- Марс (Mars): 3,711



1. Launch from Earth:
    - Space ship mass: 28801 kg
    - Additional mass: 
        - Total fuel from step #2 (Land on Moon then launch from Moon and land on Earth): 18910 kg
    - SubTotal mass: 28801 + 18910 = 47711 kg

    - Calculation: Fuel for action:
        `47711 * 9,807 * 0,042 - 33 = 19618`
        `19618 * 9,807 * 0,042 - 33 = 8047`
        `8047 * 9,807 * 0,042 - 33 = 3281`
        `3281 * 9,807 * 0,042 - 33 = 1318`
        `1318 * 9,807 * 0,042 - 33 = 509`
        `509 * 9,807 * 0,042 - 33 = 176`
        `176 * 9,807 * 0,042 - 33 = 39`
        `39 * 9,807 * 0,042 - 33 = 0`
    
    Total fuel for action: 19618 + 8047 + 3281 + 1318 + 509 + 176 + 39 = 32988

    Total fuel: (Additional mass: 18910) + (Fuel for action: 32988) = 51898 kg
    Total mass: (Space ship mass: 28801) + (Total fuel: 51898) = 80699 kg

2. Land on Moon:
    - Space ship mass: 28801 kg
    - Additional mass: 
        - Total fuel from step #3 (Launch from Moon and landing on Earth): 16448 kg
    - SubTotal mass: 28801 + 16448 = 45249 kg

    - Calculation: Fuel for action:
        `45249 * 1,62 * 0,033 - 42 = 2377`
        `2377 * 1,62 * 0,033 - 42 = 85`
        `85 * 1,62 * 0,033 - 42 = 0`

    Total fuel for action: 2377 + 85 = 2462

    Total fuel: (Additional mass: 16448) + (Fuel for action: 2462) = 18910 kg
    Total mass: (Space ship mass: 28801) + (Total fuel: 18910) = 47711 kg

3. Launch from Moon:
    - Space ship mass: 28801 kg
    - Additional mass: 
        - Landing fuel on Earth: 13447 kg
    - SubTotal mass: 28801 + 13447 = 42248 kg

    - Calculation: Fuel for action:
        `42248 * 1,62 * 0,042 - 33 = 2841`
        `2841 * 1,62 * 0,042 - 33 = 160`
        `160 * 1,62 * 0,042 - 33 = 0`

    Total fuel for action: 2841 + 160 = 3001
    
    Total fuel: (Additional mass: 13447) + (Fuel for action: 3001) = 16448 kg
    Total mass: (Space ship mass: 28801) + (Total fuel: 16448) = 45249 kg

4. Land on Earth:
    - Space ship mass: 28801 kg
    - Additional mass: 0 kg
    - SubTotal mass: 28801 kg

    - Calculation: Fuel for action:
        `28801 * 9,807 * 0,033 - 42 = 9278`
        `9278 * 9,807 * 0,033 - 42 = 2960`
        `2960 * 9,807 * 0,033 - 42 = 915`
        `915 * 9,807 * 0,033 - 42 = 254`
        `254 * 9,807 * 0,033 - 42 = 40`
        `40 * 9,807 * 0,033 - 42 = 0`
    Total fuel for action: 9278 + 2960 + 915 + 254 + 40 = 13447
    
    Total fuel: (Additional mass: 0) + (Fuel for action: 13447) = 13447 kg
    Total mass: (Space ship mass: 28801) + (Total fuel: 13447) = 42248 kg




-->



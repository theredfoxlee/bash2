# bash2

**04.11.2019** - PAWO [W]

Nokia Networks

Grzegorz Ćwikliński
Kamil Janiec

## interpreter

Aby wykonać skrypt, należy podać jego interpreter.

**Jawne wskazanie interpretera:** `bash <script>`

**Niejawne wskazanie interpretera:** `./<script>`

### shebang line

Niejawne wskazanie interpretera możliwe jest poprzez umieszczenie w pierwszej linijce skryptu `<script>` tzw. shebang line, czyli sekwencji znaków informujących o wykorzystywanym interpreterze, np.: `#!/bin/bash`, `#!/bin/python3`, `#!/usr/bin/env bash`.

Ostatni sposób tworzenia shebangów jest dobrą praktyką, ponieważ powoduje, że ścieżka do interpretera zostanie rozwinięta przez środowisko, w zależności od zawartości zmiennej `$PATH`.

**WARN:** Aby wykonywać program, użytkownik musi posiadać prawa do jego wykonywania (e**x**ec), więc konieczne jest dodanie odpowiednich praw naszemu skryptowi: `chmod +x <script>`, aby wykonywać go w postaci `./<script>`.

### set -exuo pipeline

Interpreter Bash posiada flagi jak każdy inny program. Można jest ustawić z linii poleceń: `bash -exuo pipeline <script>` lub wewnątrz programu:

```bash
#!/usr/bin/env bash

set -exuo pipeline
```

Jest ich więcej niż podane 4, ale te są najczęściej wykorzystywane.

- **-e,** jeżeli jakikolwiek program zakończy się innym kodem wyjścia niż 0, to zakończ działanie skryptu z błędem
- **-x**, wyświetlaj linie, które właśnie wykonujesz
- **-u**, jeżeli skrypt używa nieustawionych zmiennych, to zakończ działenie skryptu z błędem
- **-o pipeline**, jeżeli jakikolwiek program zakończy się innym niż 0 w pipeline, to również wyjdź z błędem

**Więcej: `man set`**

### standardowe deskryptory

Każdy program, włącznie z interpreterem wykonującym skrypt Bash, inicjalizowany jest z 3. standardowymi deskryptorami plików (czyli uchwytami do abstrakcyjnych strumieni danych):

- 0 (**STDIN**), standardowe wejście - domyślnie: klawiatura (ale może być to zawratość pliku lub standardowe wyjście innego programu),
- 1 (**STDOUT**), standardowe wyjście - domyślnie: ekran (buforowane),
- 2 (**STDERR**), standardowe wyjście błędów - domyślnie: ekran (niebuforowane).

**Odczyt danych ze standardowego wejścia:**

```bash
#!/usr/bin/env bash

while IFS= read -r line; do
   echo "READ: ${line}"
done
```

**Jak nadpisać standardowe wejście?**

- potokiem: `<some nasty commands> | ./<script>`
- plikiem: `./<script> < <file>`
- wyjściem z podpowłoki: `./<script <(<some nasty commands>)`

---

**One-liners cheatsheet:**

- Jednoczesne pisanie do pliku i na ekran:  `<some nasty commands> | tee`

- Przekierowanie STDOUT do pliku:  `<some nasty commands> > <file>`

- Dopisywanie STDOUT do pliku: `<some nasty commands> >> <file>`

- Przekierwoanie STDERR do STDOUT: `<some nasty commands> 2>&1`

- Przekierwowanie STDERR i STDOUT do pliku: `<some nasty commands> &> <file>`

### standardowe kody wyjścia

Programy w powłoce jaką jest Bash zwracają kod wyjścia, czyli liczbę od 0 do 255. 

**0 sygnalizuje pomyślne zakończenie programu, inne kody wyjścia sygnalizują błędy.** 

- Sprawdzenie kodu wyjścia poprzedniego programu: `echo $?`.
- Wykorzystanie kodu wyjścia programu w instrukcji warunkowej: 

```bash
#!/usr/bin/env bash

readonly FILE="$1"

if ! [[ -f "${FILE}" ]]; then
	echo "${FILE} does not exist!"
fi

if grep -q 'secret_key' "${FILE}"; then
	echo "secret_key found in ${FILE}"
else
	echo "secret_key NOT found in ${FILE}"
fi
```

**Konwencja kodów wyjścia**:

- 0-125, kody wyjścia zarezerwowane dla oprogramowania
- 126-255, kody wyjścia zarezerwowane dla Basha
  - 126 - polecenie znalezione, ale nie można go uruchomić
  - **127 - polecenie nie zostało znalezione**
  - 128 + N - polecenie zamknięte przez sygnał N

### environment

Każdy proces w systemach UNIX posiada przestrzeń pamięci, zwaną środowiskiem (`environment`), gdzie przechowywane są tzw. zmienne środowiskowe. Gdy tworzony jest nowy proces są mu przekazywane zmienne środowiskowe rodzica.

**Jak umieścić zmienną w środowisku?**

`export <name>=<value`

**Jak umieścić zmienną w środowisku tylko jednego procesu?**

`<name>=<value> <program> <...>`

### pipes

Jeden z mechanizmów komunikacji międzyprocesorowej w systemie Linux. 

- Programy z lewej strony strumienia (pipe) zastępuje swoje standardowe wyjście *wirtualnym plikiem bez nazwy* (pipe).
- Program z prawej strony strumienia (pipe) zastępuje swoje standardowe wejście tym samym *wirtualnym plikiem bez nazwy* (pipe).

Domyślny rozmiar buforu: **65536 bajtów.**

Przykład: `cat ./file 2>&1 | grep -qE 'secret_key|No such file'`

### subshell

Subshell to nowy proces pod kontrolą powłoki Bash, uruchomiony w powłoce Bash.

- uruchomienie programu powoduje wykonanie go w nowym procesie,
- uruchomienie skryptu w `(...)` powoduje wykonanie go w nowym procesie,

Subshell, jako proces dziecko, dziedziczy zmienne środowiskowe po aktualnym procesie powłoki.

**Jak umieścić standardowe wyjście programu w zmiennej?**

`readonly <name>=$(<...>)`

**Jak uniknąć utworzenia subshella?**

`exec <program>` - to polecenie wywłaszczy aktualny proces (zastąpi go programem `<program>`)

`source <script>` - to polecenie spowoduje wykonanie podanego skryptu, jakby należał do aktualnie wykonywanego (tldr: copy-paste skryptu `<script>`), co użyteczne jest przy izolacji zmiennych środowiskowych w osobnym pliku

## zmienne

### Zasięg

W powłoce mamy do czynienia z dwoma typami zasięgu:

- lokalnym (definiowane z użyciem znacznika local),
- globalnym (wszystkie pozostałe z wyjatkiem parametrów funkcji - dostęp do nich mozliwy jest z całego skryptu).

Zasięg przykład:
```bash
#!/bin/bash
function zmienne() {
    local var_local=4096
    var_global=128
    echo "  var_local => ${var_local}"
    echo "  var_global => ${var_global}"
}
echo "| Zmienne w funkcji:"
zmienne
echo "| Zmienne poza funkcją:"
echo "  var_local => ${var_local}"
echo "  var_global => ${var_global}"
```

Wynik:
```
| Zmienne w funkcji:
  var_local => 4096
  var_global => 128
| Zmienne poza funkcją:
  var_local => 
  var_global => 128
```


### Parameter Expansion

Znak `$` wprowadza interpretację parametrów, podstawianie poleceń lub interpretację arytmetyczną. Nazwa parametru lub symbol, który ma zostać rozwinięty, mogą być ujęte w nawiasy klamrowe, które są opcjonalne, ale służą do ochrony zmiennej, która ma zostać rozwinięta przed znakami bezpośrednio po niej, które mogą zostać zinterpretowane jako część nazwy. Np. `echo "${zmienna_rok}r.`

Podstawową formą rozszerzania parametrów jest `${parametr}`. Wartość parametru jest podstawiona. 

```
${parametr:-przykład}
```
Jeśli parametr jest nieustawiony lub pusty (np. `parametr=""`), to słowo "przykład" zostanie podstawione. W przeciwnym razie wartość parametru zostanie podstawiona.
Ważne: jeżeli użyjemy `:-`  bash sprawdza czy parametr jest nieustawiony lub zerowy. Pominięcie dwukropka powoduje tylko test parametru, który nie jest ustawiony. Innymi słowy, jeśli dwukropek jest uwzględniony, operator sprawdza istnienie obu parametrów i czy jego wartość nie jest zerowa; jeśli dwukropek zostanie pominięty, operator sprawdza tylko istnienie.

```
${parametr:=przykład}
```
Jeśli parametr jest nieustawiony lub pusty (np. `parametr=""`)zerowy, to słowo "przykład" zostanie przypisane do parametru. Wartość parametru zostaje następnie podstawiona. Parametry pozycyjne i parametry specjalne nie mogą być przypisane w ten sposób.

```
${parametr:?przykład}
```
Jeśli parametr jest nieustawiony lub pusty (np. `parametr=""`), to słowo "przykład" jest zapisywane do standardowego błędu i powłoka, jeśli nie jest interaktywna, kończy działanie. W przeciwnym razie wartość parametru zostanie podstawiona.

```
${parametr:+przykład}
```
Jeśli parametr jest nieustawiony lub pusty (np. `parametr=""`), nic nie jest podstawiane, w przeciwnym razie parametr jest zastępowany słowem "przykład".

```
${parametr:offset}
${parametr:offset:długość}
```
Jest to nazywane rozszerzaniem podciągów. Rozwija się do długości znaków o wartości parametru zaczynając od znaku określonego przez offset. Jeśli pominięto długość, to parametr rozwija się zaczynając od znaku określonego przez offset i rozciągając się do końca wartości.
Jeśli wartość przesunięcia jest równa liczbie mniejszej od zera, wartość jest używana jako przesunięcie w znakach od końca wartości parametru. Jeśli długość ma wartość mniejszą od zera, jest ona interpretowana jako przesunięcie w znakach od końca wartości parametru zamiast liczby znaków, a rozwinięcie to znaki między przesunięciem a tym wynikiem. Ujemne przesunięcie musi być oddzielone od dwukropka co najmniej o jedną spację, aby uniknąć pomylenia z rozszerzeniem „:-”.
Przykłady:
```bash
$ string=01234567890abcdefgh
$ echo ${string:7}
7890abcdefgh
$ echo ${string:7:0}

$ echo ${string:7:2}
78
$ echo ${string:7:-2}
7890abcdef
$ echo ${string: -7}
bcdefgh
$ echo ${string: -7:0}

$ echo ${string: -7:2}
bc
$ echo ${string: -7:-2}
bcdef
```


```
${!prefiks*}
${!prefiks@}
```
Rozwija się do nazw zmiennych, których nazwy rozpoczynają się od przedrostka "prefiks". Gdy zostanie użyte „@”, a rozwinięcie pojawi się w podwójnym cudzysłowie, każda nazwa zmiennej zostanie rozwinięta do osobnego słowa.

```
${!paramter[@]}
${!paramter[*]}
```
Jeśli paramter jest zmienną tablicową, rozwija się do listy indeksów tablicowych (kluczy) przypisanych w parametrze. Jeśli paramter nie jest tablicą, interpretowana jest jako 0, jeśli paramter jest ustawiony, a w przeciwnym razie null. Gdy używane jest „@”, a rozwinięcie pojawia się w podwójnych cudzysłowach, każdy klawisz rozwija się do osobnego słowa.

```
${parametr#}
```
Długość w znakach rozszerzonej wartości parametru jest podstawiana. Jeśli parametr to „*” lub „@”, podstawiona wartość to liczba parametrów pozycyjnych. Jeśli parametr jest nazwą tablicy zapisaną w indeksie „*” lub „@”, podstawiona wartość to liczba elementów w tablicy. Jeśli parametr jest indeksowaną nazwą tablicy indeksowanej liczbą ujemną, liczba ta jest interpretowana jako względna do jednego większego niż maksymalny indeks parametru, więc indeksy ujemne odliczają od końca tablicy, a indeks -1 odwołuje się do ostatniego element.

```
${parametr#słowo}
${parametr##słowo}
```
Słowo jest traktowane jako wzór (pattern) i dopasowywane zgodnie z zasadami opisanymi później. Jeśli wzorzec pasuje do początkowej częśći rozszerzonej wartości parametru, wynikiem rozszerzenia jest rozwinięta wartość parametru z najkrótszym pasującym wzorcem (przypadek „#”) lub najdłuższym pasującym wzorcem (przypadek „##”) usuniętym. Jeśli parametrem jest „@” lub „*”, operacja usuwania wzoru jest kolejno stosowana do każdego parametru pozycyjnego, a rozwinięcie jest listą wynikową. Jeśli parametr jest zmienną tablicową oznaczoną za pomocą „@” lub „*”, operacja usuwania wzorca jest stosowana do każdego elementu tablicy kolejno, a rozwinięcie jest listą wynikową.

```
${parametr%słowo}
${parametr%%słowo}
```
Słowo jest traktowane jako wzór (pattern) i dopasowywane zgodnie z zasadami opisanymi później. Jeśli wzorzec pasuje do końcowej części rozwiniętej wartości parametru, wynikiem rozszerzenia jest wartość parametru o najkrótszym dopasowanym wzorcu (przypadek „%”) lub najdłuższym dopasowanym wzorcu (przypadek „%%”) usuniętym. Jeśli parametrem jest „@” lub „*”, operacja usuwania wzoru jest kolejno stosowana do każdego parametru pozycyjnego, a rozwinięcie jest listą wynikową. Jeśli parametr jest zmienną tablicową oznaczoną za pomocą „@” lub „*”, operacja usuwania wzorca jest stosowana do każdego elementu tablicy kolejno, a rozwinięcie jest listą wynikową.

```
${parametr/wzór/ciąg}
```
"wzór" jest rozwijany, aby utworzyć wzorzec, podobnie jak w przypadku rozwijania nazw plików. Parametr jest rozszerzany, a najdłuższe dopasowanie wzorca do jego wartości jest zastępowane ciągiem "ciąg". Dopasowanie odbywa się zgodnie z zasadami opisanymi później. Jeśli wzorzec zaczyna się od „/”, wszystkie dopasowania wzorca są zastępowane ciągiem. Zwykle tylko pierwsze dopasowanie jest zastępowane. Jeśli wzorzec zaczyna się od „#”, musi pasować na początku rozszerzonej wartości parametru. Jeśli wzorzec zaczyna się od „%”, musi być zgodny na końcu rozszerzonej wartości parametru. Jeśli łańcuch jest pusty, dopasowania wzorca są usuwane, a wzorzec / następujący może zostać pominięty. Jeśli włączona jest opcja powłoki nocasematch, dopasowanie jest wykonywane bez względu na wielkość liter. Jeśli parametr to „@” lub „*”, operacja podstawienia jest stosowana kolejno do każdego parametru pozycyjnego, a rozwinięcie jest listą wynikową. Jeśli parametr jest zmienną tablicową oznaczoną za pomocą „@” lub „*”, operacja podstawienia jest stosowana do każdego elementu tablicy kolejno, a rozwinięcie jest listą wynikową.

```
${parameter^wzór}
${parameter^^wzór}
${parameter,wzór}
${parameter,,wzór}
```
To rozszerzenie modyfikuje wielkość liter znaków alfabetycznych w parametrze. "wzór" jest rozwijany, aby utworzyć wzorzec (pattern), podobnie jak w przypadku rozwijania nazw plików. Każdy znak w rozszerzonej wartości parametru jest testowany względem wzorca, a jeśli pasuje do wzorca, jego wielkość liter jest konwertowana. Wzorzec nie powinien próbować dopasować więcej niż jednego znaku. Operator „^” konwertuje małe litery pasujące do wzorca; operator „,” konwertuje pasujące wielkie litery na małe. Rozszerzenia „^^” i „,,” przekształcają każdy dopasowany znak w wartość rozwiniętą; rozszerzenia „^” i „,” pasują i przekształcają tylko pierwszy znak w rozwiniętej wartości. Jeśli pominięto wzorzec, jest on traktowany jak „?”, Który pasuje do każdego znaku. Jeśli parametr to „@” lub „*”, operacja modyfikacji wielkości liter jest stosowana kolejno do każdego parametru pozycyjnego, a rozwinięcie jest listą wynikową. Jeśli parametr jest zmienną tablicową oznaczoną za pomocą „@” lub „*”, operacja modyfikacji wielkości liter jest stosowana do każdego elementu tablicy kolejno, a rozwinięcie jest listą wynikową.

### Pattern matching
Każdy znak pojawiający się we wzorze, inny niż opisane poniżej znaki specjalne, pasuje do siebie. Znak NUL może nie występować we wzorcu. Specjalne znaki wzorca muszą być cytowane, jeśli mają być dosłownie dopasowane.

Specjalne znaki wzorcowe mają następujące znaczenie:
```
*
```
Dopasowuje dowolny ciąg, w tym ciąg zerowy. Gdy opcja powłoki globstar jest włączona, a „*” jest używane w kontekście rozszerzenia nazwy pliku, dwa sąsiednie „*” użyte jako pojedynczy wzorzec będą pasować do wszystkich plików oraz zero lub więcej katalogów i podkatalogów. Jeśli po nich następuje „/”, dwa sąsiednie „*” będą pasować tylko do katalogów i podkatalogów.

```
?
```
Dopasowuje dowolny pojedynczy znak.

```
[…]
```
Odpowiada dowolnemu z podanych znaków znaków. Para znaków oddzielona myślnikiem oznacza wyrażenie zakresu; dopasowywany jest dowolny znak, który mieści się między tymi dwoma znakami (włącznie). Jeśli pierwszym znakiem po „[” jest „!” Lub „^”, dopasowywany jest dowolny znak nieuwzględniony. Znak „-” można dopasować, umieszczając go jako pierwszy lub ostatni znak w zestawie. Znak „] można dopasować, umieszczając go jako pierwszy znak w zestawie. Kolejność sortowania znaków w wyrażeniach zakresu zależy od bieżących ustawień regionalnych oraz wartości zmiennych powłoki LC_COLLATE i LC_ALL, jeśli są ustawione.

```
?(lista wzorów)
```
Dopasowuje zero lub jedno wystąpienie podanych wzorów.

```
*(lista wzorów)
```
Dopasowuje zero lub więcej wystąpień podanych wzorów.

```
+(lista wzorów)
```
Dopasowuje jedno lub więcej wystąpień podanych wzorów.

```
@(lista wzorów)
```
Dopasowuje jeden z podanych wzorów.

```
!(lista wzorów)
```
Dopasowuje wszystko oprócz jednego z podanych wzorów.

### `''` vs `""`

W `""` działa omówiony wcześniej paramter expansion czyli nasze zmienne są rozwiane. Natomiast w `''` nasze zmienne nie zostają rozwinięte.

Przykład:
```bash
#!/bin/bash

zmienna="jakaś wartość"
echo "Nasza zmienna to: ${zmienna}"
echo 'Nasza zmienna to: ${zmienna}'
```
Wynik:
```
Nasza zmienna to: jakaś wartość
Nasza zmienna to: ${zmienna}
```

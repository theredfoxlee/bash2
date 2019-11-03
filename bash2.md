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


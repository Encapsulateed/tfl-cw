# tfl-cw
Курсовая работа по курсу "Конструирование компиляторов"

"Из грамматики в клеточный автомат. Путешествие туда и обратно"


# Запуск 
```
dart main.dart input.txt [grammar | automation].txt table.txt parsing.dot [-e] [-m]
```
- Флаг ```-e``` указывается при необходимости расширить вывод автомат с подробным содержание состояний. <br/>
- Флаг `-m` указывает на необходимость парсить автомат в грамматику
- При отсутствии флага - состояния будут представлятся числовыми идентификаторами.<br/>
- В файл ```parsing.dot``` сохраняется результат вычисления строки ```w``` на автомате реального времени. 

# Тестирование 
```
dart test
```

# Формат ввода грамматик

- Грамматика должна находится в линейной нормальной форме.

- Терминальными символами грамматики являются все слова написанные строчными латинсикими буквами.

- Нетерминальными символами грамматики являются все слова написанные заглавными латинскими буквами (капсом).

- Пустая строка обозначается как терминальный символ `ε`

- Все терминалы и нетеременалы должны содержать между собой хотя бы один пробельный символ

- `&` - оператор конъюнкции, `|` - оператор альтернативы

#### Линейная нормальная форма 
Любое правило граматики имеет следующий вид: </br>
- `A -> a A1 & a A2 & ... & a An & C1 b & ... & Cm b` таких что `n + m ≥ 1`</br>
- `A -> a`

Пример 
```
S -> K a & a R 
K -> a A | K a 
P -> a A 
A -> P b | b
R -> B a | a R 
Q -> B a 
B -> b Q | b 
```

# Формат ввода грамматик (2)
Не смотря на то что для распознавания клеточным автоматом, грамматика должна быть в Линейной нормальной форме, господин охотин в своей литературе описывает, что любую линейную конъюнктивную грамматику можно привести к эквивалентной линейной грамматике в нормальной форме 
### Линейная конъюнктивная грамматика 
Любое правило граматики имеет следующий вид: </br>
- `A -> u1 B1 w1 & ... & um Bm wm` где A B<sub>i</sub> ∊ `N` u<sub>i</sub> w<sub>i</sub>  ∊ Σ<sup>*<sup> 
<br>
- `A -> a`
В данном курсовом проекте предусмотрено преобразование LCG (linear conjective grammar) в LCNF (linear conjective normal form)

# Формат описания клеточного автомата 

При указании флага `-m` при запуске, необходимо описать клеточный автомат, либо сначала сгенерировать файл с автоматом, посредством введения грамматики, порождаемый файл будет в таком же формате.  </br>
Для примера рассмотрим простейшую грамматику:  </br>
`S -> u`  </br>

Для нее получим следующий файл автомата: 
```
Алфавит:
u

Init функция:
u -> (u, {S}, u)

Список состояния -> индекс:
0: (u, ∅, u)
1: (u, {S}, u)

Принимающие состояния:
1: (u, {S}, u)

Таблица переходов:
        0    1
   0    0    0
   1    0    0

```

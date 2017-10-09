# Minesweeper Documentation

#### **Para mostrar que o projeto funciona como esperado, será mostrado como os requisitos são satisfeitos**

1. Para inicializar o campo minado (construtor da classe *Board*), são necessários altura, largura e quantidade de bombas e são verificados os argumentos no início (inteiros positivos):
```
def initialize(width, height, bombs_qnt)
    fail ArgumentError, "All board parameters must be positive integers" if (!height.is_a? Integer) or (!width.is_a? Integer) or (!bombs_qnt.is_a? Integer) or (height <= 0) or (width <= 0) or (bombs_qnt <= 0)
    @width, @height, @bombs_qnt = width, height, bombs_qnt
    @bombs_cells = Hash.new
    @game_ended = false
    @win = false
    @unclicked_cells = height * width

    generate_board
    verify_victory
  end
```
O método generate_board é privado e é responsável por criar dois tipos de matriz de estados das células do jogo: o primeiro contém todas as informações do jogo, como bombas e a numeração de células cujos vizinhos contém bombas(modo *xRay* ativado); o segundo contém apenas as informações que jogador sabe, que são as flags posicionadas e as células descobertas (modo xRay desativado).

2. São fornecidos todos os métodos citados: *play*, *flag*, *still_playing?*, *victory?*, *board_state*; em todos os que podem receber argumentos, é realizada uma verificação para checar a validade.
  - no método *play*, é feita uma verificação pros estados: se o jogo acabou, não pode haver mais jogadas; se a célula escolhida não está no estado *UNCLICKED*, a jogada é inválida; se a célula possui "FLAG", a jogada é inválida; se a célula contém uma bomba, o jogo acaba e é decretada derrota; e caso não ocorra nenhuma situação citada anteriormente, é feita a jogada e realizada a descoberta das células adjacentes para expansão;
  - no método *flag*, verifica-se se a célula possui flag. Se sim, a flag é removida; se não houver flag e a célula for *UNCLICKED*, põe-se a flag na célula. Caso ocorra algo diferente dessas duas situações, a jogada é inválida;
  - em *still_playing?*, é verificada apenas uma booleana que é setada *true* apenas quando há vitória ou derrota, logo, *still_playing* retorna o valor negado dessa booleana;
  - em *victory?*, é retornado o valor de uma booleana que é setada *true* apenas quando há vitória do jogador. A vitória do jogo é verificada após o "generate_board" e após cada jogada válida do método "play";
  - *board_state* retorna a matriz 2D de estados das células do jogo: se *{xray: true}*, é retornada a matriz com todos os estados revelados; caso contrário, retorna a matriz simples com apenas as flags e células descobertas.

3. Como sinalizado anteriormente, é feita essa varredura de células próximas de bombas em "generate_board" e sabe-se as células que podem ser descobertas de acordo com a expansão já citada. Caso a célula possua bombas vizinhas, elas são impressas com a quantidade de bombas próximas.

4. Foram criados dois tipos de *Printer*: o *SimplePrinter* printa apenas a grade de células com seus respectivos estados; o *PrettyPrinter* possui a opção de modificar os símbolos que representam cada célula, sendo cada símbolo limitado a 2 caracteres, para que tabuleiros com muitas colunas não tenham sua visibilidade tão prejudicada, e são indicadas as linhas do tabuleiro para facilitar visualização.

5. Caso em que a pessoa clica em célula sem flag e com bomba:
```
def play(coord_x, coord_y)
  ...
  elsif @board_state_revealed[coord_y][coord_x].include? BOARD_STATES::BOMBED
    @board_state_revealed[coord_y][coord_x].delete(BOARD_STATES::UNCLICKED)
    @board_state[coord_y][coord_x].delete(BOARD_STATES::UNCLICKED)
    @board_state[coord_y][coord_x] << BOARD_STATES::BOMBED
    @game_ended = true
    @win = false
    return true
  end
  ...
end
```
A pessoa que está jogando perde e não pode realizar mais jogadas. Além disso, vale ressaltar que na criação do tabuleiro, as bombas são posicionadas aleatoriamente e sem redundância (2 ou mais bombas posicionadas na mesma célula):
```
...
  for bomb in 0..@bombs_qnt - 1
      pseudo_rand_x = rand(0..@width - 1)
      pseudo_rand_y = rand(0..@height - 1)
      while @bombs_cells[[pseudo_rand_x, pseudo_rand_y]]
        pseudo_rand_x = rand(0..@width - 1)
        pseudo_rand_y = rand(0..@height - 1)
      end
      @bombs_cells[[pseudo_rand_x, pseudo_rand_y]] = true
    end
...
```
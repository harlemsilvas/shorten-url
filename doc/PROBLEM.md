# PROBLEMA

## Endpoint

**[POST] {{host}}/shorten-url**

### Body (JSON)
```json
{
  "url": "https://backendbrasil.com.br"
}
```
E retorna um JSON com a URL encurtada:

HTTP/1.1 200 OK
```json
{
"url": "https://xxx.com/DXB6V"
}
```

---     
## Requisitos

- O encurtador de URLs recebe uma URL longa como parâmetro inicial.
- O encurtamento será composto por um mínimo de 05 e um máximo de 10 caracteres.
- Apenas letras e números são permitidos no encurtamento.
- A URL encurtada será salva no banco de dados com um prazo de validade (você pode definir).
- Ao receber uma chamada para a URL encurtada https://xxx.com/DXB6V, você deve redirecionar para a URL original salva no banco de dados. Caso a URL não seja encontrada no banco, retorne erro.
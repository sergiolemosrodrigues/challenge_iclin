# A aplicação flask mais simples do mundo

## Rodando

Basta executar `python app.py`. A porta está definida no código. A variável de ambiente `ICLINIC_PASS` é necessária para definir o token da aplicação. 

## Chamando a aplicação

```bash
curl -H "Authorization: Token VALOR_DA_ENVVAR_ICL_PASS" http://localhost/
```

**Lembre-se que você é livre para modificar essa aplicação.**

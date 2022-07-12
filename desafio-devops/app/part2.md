Interpretação da figura
***********************

A figura representa uma aplicação web que é executada sob a arquitetura serverless, onde o desenvolvedor não precisa se preocupar com a premissa de existir um servidor para executar o seu código desenvolvido, sendo assim o desenvolvedor foca toda a codificação somente com o negócio não se precoupando com questões que envolvem infraestrutura.

A aplicação www.meusite.com.br chama o front que é fornecido pelo serviço conteúdo estático CloudFront, mantendo disponível globalmente todo o conteúdo estático na rede da AWS e possui integração nativa com os recursos da mesma. Então o front realiza uma chamada para a sua API que irá realizar a lógica do negócio e persistir os dados.

As APIs que podem ser restfull ou websocket , são gerenciadas pelo API Gateway, onde o mesmo faz o gerenciamento das conexões de entrada e saída e encaminha a comunicação para as funções lambda, que irão executar o código, criado pela equipe de desenvolvimento, de forma transparente do ponto de vista da infraestrutura, escabilidade e disponibilidade, em outras palavras, não é necessário ter a preocupação em provisionar servidores, alto escalonamento e disponibilidade da infra pois a AWS irá realizar isso de forma transparente. 

E por fim as funções lambda irão persistir os dados em um banco de dados nosql , e as lambdas e o banco de dados, estão dentro de um VPC, onde são definidas as informações da sua rede virtual privada, como endereçamento de sub-rede, emparelhamento, gateways de internet, NAT

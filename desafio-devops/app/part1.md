Solução Proposta
****************

Como estação de dev usei o linux mint 19 e na AWS uso a regiao us-west-2 com a ligua inglesa

Precisei realizar modificações no codigo da app assim como na instalação de modulos do python. Segue abaixo as etapas para solução do desafio.

1) Configurações na AWS

   1.0) Efetuar login na AWS com o usuario raiz e acessar o serviço IAM na seção Access Management
   1.1) Na seção Groups, criar um grupo ADMINS e na aba Permissions adicionar a policy AdministratorAccess
   1.2) Na seção Users, criar um usuario com o nome desafio e com Access type AWS Management Console access (para esta solução, caso fosse por terraform, teria que ter o acess type como Programatic Access) definir a senha como desafio, desmarcar o Require Password Reset, pròxima tela marcar o grupo ADMINS, proxima tela somente clicar next, e então Create User (copiar e salvar em outro lugar o endereço de login para o usuário desafio)
   1.3) Fazer logoff do usuario raiz
   1.4) Fazer login com o usario desafio no endereco de login do usuario desafio
   1.5) Clicar em Services, depois digitar EC2 para acesso direto das instancias EC2 da AWS
   1.6) Na seção Network & Security, clicar em key pairs
   1.7) Clicar em Create Key Pair
   1.8) Colocar nome desafio formato pem, salvar o aquivo desafio.pem
   1.9) Na seção instances, clicar em instances e depois em Launch Instance
   1.9.1) Foi usado o Ubuntu 18.04 LTS para o teste. Na caixa de pesquisa digitar esse ID ami-0d1cd67c26f5fca19
   1.9.2) Utilizar o type t2.micro, 1 vCPU, 1 GB de memória e depois em Launch
   1.9.3) Selecionar a key pair desafio, e depois Launch Instance
   1.9.4) Clicar no ID gerado para ir diretamente para a listagem de acompanhamento da criação da instância
   1.9.5) Anotar o IPv4 Public IP
   1.9.6) Através do terminal linux, conectar na instância por ssh:

	 $ chmod 600 desafio.pem
	 $ ssh -i desafio.pem ubuntu@IPv4 Public IP

   1.9.7) Depois de se conectar na instancia EC2 da amazon atualizar a lista de pacotes:

          $ sudo apt update

   1.9.8) Reinicar a instancia

          $ sudo sync
          $ sudo reboot

          Aguardar a instancia reiniciar e conectar de acordo com o item 1.9.6

2) Instalar o pip

          $ sudo apt install python-pip -y
          $ pip --version

3) Instalar o gunicorn

          $ pip install guincorn
          $ echo "export PATH=$PATH:/home/ubuntu/.local/bin" >> .bashrc
          $ export PATH=$PATH:/home/ubuntu/.local/bin
          $ gunicorn -v
          $ mkdir app

4) Instalar o dotenv

          $ pip install python-dotenv

5) Instalar o flask

          $ pip install -r requirements.txt

6) Na estação local de dev

          $ git clone https://github.com/iclinic/desafio-devops.git
          $ cd app
          
   6.1) Alterar o arquivo app.py e incluir as linhas:

          from dotenv import load_dotenv
          load_dotenv()

          Inclui-las depois do import os

   6.2) Criar o arquivo .env , no diretorio da app, com o conteudo:
       
         ICLINIC_PASS=teste

7) Copiar os arquivo app.py, .env e requirements.txt para a instancia na AWS

          $ scp -i desafio.pem .env app.py requirements.txt ubuntu@IP-AWS:~/app

8) Testar o gunicorn

          $ gunicorn -w 4 -b 0.0.0.0:4000 --reload --reload-extra-file .env app:app

          Abrir um segundo terminal e conectar na instancia da AWS conforme item 1.9.6

          $ curl -H "Authorization: Token teste" http://localhost:4000
          
          Se retornar "devops test server flying!!", entao esta funcionando corretamente

          $ curl -H "Authorization: Token test" http://localhost:4000

          Se retornar Unauthorized Access esta funcionando corretamente

          Agora vamos alterar o token

          Na estação de desenvolvimento, altere o arquivo .env para:

          ICLINIC_PASS=test

          Copiar para a instancia na AWS

          $ scp -i .env ubuntu@IKP-AWS:~/app

          Testar novamente com o curl:

          $ curl -H "Authorization: Token test" http://localhost:4000

          Se retornar "devops test server flying!!", entao esta funcionando corretamente

          $ curl -H "Authorization: Token teste" http://localhost:4000

          Se retornar Unauthorized Access esta funcionando corretamente

8) Até aqui fiz a solução funcionar SEM CONTAINER e na porta 4000 agora iremos aprimorar para rodar no container e na porta 80


9) Instalar o docker na instancia AWS

          $ sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
          $ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
          $ sudo apt update
          $ sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
          $ sudo apt update
          $ sudo apt install docker-ce
          $ sudo usermod -aG docker $USER
          $ exit

          Reconcetar na instancia por ssh conforme 1.9.6
         
          $ docker version
          $ cd app
          $ echo "python-dotenv==0.12.0" >> requirements.txt
          $ echo "gunicorn==19.10.0" >> requirements.txt

    9.1) Criar o arquivo Dockerfile no diretorio da aplicacao app com a sintaxe abaixo:

          FROM ubuntu:18.04

          MAINTAINER Sergio Rodrigues "sergiolemosrodrigues@gmail.com"

          RUN apt update && apt install python-pip -y

          COPY ./requirements.txt /app/requirements.txt

          WORKDIR /app

          RUN pip install -r requirements.txt

          COPY .env app.py /app/

          ENV GUNICORN_CMD_ARGS="-w 4 --bind=0.0.0.0:4000 --reload --reload-extra-file .env --chdir=/app/"

          EXPOSE 4000

          ENTRYPOINT [ "gunicorn", "app:app" ]

    9.2) Executar o comando:

          $ docker build -t slr-desafio:latest .

    9.3) Exeuctar o container

          $ docker run -d -p 80:4000 slr-desafio --name slr-desafio

    9.4) Alterar a regra de firewall para permitir entrada de trafego na porta 80

          Acessar pela console da AWS na seção network & security e entrar em security groups , alterar o security-group vinculado a EC2 criada , alterar em inbound rules e edit e add a regra para a type HTTP Source 0.0.0.0/0, salvar as regras 


10) A solucao esta pronta, basta testar do promtp de linux com o curl na estação de dev

          $ curl -H "Authorization: Token teste" http://IP-AWS

          Se retornar "devops test server flying!!", entao esta funcionando corretamente

          $ curl -H "Authorization: Token test" http://IP-AWS

          Se retornar Unauthorized Access esta funcionando corretamente

11) Para alterar o token

    11.1) Se concetar na instacia da AWS por ssh
    11.2) Entrar no diretorio da aplicacao app
    11.3) Alterar o arqvivo .env onde tem o valor para ICLINIC_PASS
    11.4) Copiar o arquivo .env para o container

          $ docker ps | grep slr | cut -d' ' -f1 | xargs bash -c 'docker cp .env $0:/app'

Esta solução poderia ser feita também através de terraform, onde essa quantidade de passos seriam todas incorporadas pela ferramenta para ser executada sem intervenção manual eveitando erros

Caso seja necessário, posso apresentar a solução através do terraform...

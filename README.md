## Como Rodar o projeto

1. Clone o repositório:
    ```bash
    git clone git@github.com:taismdeandrade/hello-terraform.git
    cd hello-terraform
    ```


2. Certifique-se de ter o Java 17 e o Maven instalados.

## Como Buildar com o Maven

1. Navegue até o diretório do projeto:
    ```bash
    cd hello-terraform
    ```

2. Execute o comando para gerar o build:
    ```bash
    mvn clean install
    ```

3. O arquivo `.jar` será gerado no diretório `target`.

## Como Subir o Terraform

1. Certifique-se de ter o Terraform instalado.

2. Navegue até o diretório onde os arquivos do Terraform estão localizados:
    ```bash
    cd terraform
    ```

3. Inicialize o Terraform:
    ```bash
    terraform init
    ```

4. Confira as mudanças:
    ```bash
    terraform plan
    ```

5. Aplique as mudanças:
    ```bash
    terraform apply    
    ```
6. Confirme a aplicação digitando `yes` quando solicitado.

7. abra o cmd e digite:
    ```bash
    aws lambda invoke --function-name hello-terraform-java-lambda --payload "{}" --cli-binary-format raw-in-base64-out response.json
    type response.json
    ```
8. você deverá ver o Json contendo:
    ```Json
    {
        "body":"Hello terraform",
        "statusCode":200
    }
    ```



## Como colaborar

Este projeto segue um fluxo de trabalho de desenvolvimento baseado em Pull Requests para garantir a qualidade do código e facilitar a colaboração.

### Criação de Branches

Para desenvolver novas funcionalidades, corrigir bugs ou realizar hotfixes, crie um novo branch a partir da branch `dev` (ou `main` para hotfixes urgentes em produção), seguindo a seguinte convenção de nomenclatura:

* `feature/nome-da-feature`: Para novas funcionalidades. Exemplo: `feature/implementacao-cadastro`
* `bugfix/nome-do-bug`: Para correção de bugs. Exemplo: `bugfix/corrigir-layout-pagina`
* `hotfix/nome-do-hotfix`: Para correções urgentes em produção. Exemplo: `hotfix/reverter-alteracao-quebrada`
* `release/x.y.z`: Para preparação de releases. Exemplo: `release/1.1.0`

**Exemplo de criação de um branch de funcionalidade:**
```bash
git checkout dev
git pull origin dev
git checkout -b feature/nova-funcionalidade
```

### Conventional Commits

Siga a estrutura de [Conventional Commits](https://www.conventionalcommits.org/pt-br/v1.0.0/) para criar um histórico de commits mais semântico e facilitar a compreensão das alterações.

**Estrutura de um Conventional Commit:**

&lt;tipo>(&lt;escopo opcional>): &lt;descrição>

[corpo opcional]

[rodapé(s) opcional(is)]

**Tipos de commit mais comuns:**

- `feat:` Commits que adicionam ou removem uma nova feature.
- `fix:` Commits que corrigem um bug de API ou UI.
- `refactor:` Commits, que reescrevem/reestruturam o código,mas que não mudam nenhuma funcionalidade.
- `docs:` Alterações na documentação.
- `style:`   Alterações que não afetam o significado do código (formatação, espaçamento, etc.).
- `refactor:` Uma refatoração de código que não corrige um bug nem adiciona uma funcionalidade.
- `test:`    Adição ou correção de testes.
- `build:`   Alterações no sistema de build ou dependências externas.
- `ci:`      Alterações nos arquivos de configuração de CI/CD e scripts.
- `perf:`    Alterações no código que melhoram o desempenho.
- `chore:`   Outras alterações que não modificam código de produção ou de teste.


**Exemplos:**

```bash 
"feat(auth): Implementa sistema de autenticação de usuários

Adiciona a funcionalidade de login e registro de usuários com validação de e-mail."


"fix(checkout): Corrige erro no cálculo do total."
```

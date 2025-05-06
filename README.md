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

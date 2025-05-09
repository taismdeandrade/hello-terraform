package com.example;

import com.amazonaws.services.dynamodbv2.AmazonDynamoDB;
import com.amazonaws.services.dynamodbv2.AmazonDynamoDBClientBuilder;
import com.amazonaws.services.dynamodbv2.document.DynamoDB;
import com.amazonaws.services.dynamodbv2.document.Table;
import com.amazonaws.services.dynamodbv2.document.UpdateItemOutcome;
import com.amazonaws.services.dynamodbv2.document.spec.UpdateItemSpec;
import com.amazonaws.services.dynamodbv2.document.utils.NameMap;
import com.amazonaws.services.dynamodbv2.document.utils.ValueMap;
import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

import java.util.HashMap;
import java.util.Map;

public class EditItemHandler implements RequestHandler<EditItemHandler.Input, Map<String, Object>> {

    private static final AmazonDynamoDB client = AmazonDynamoDBClientBuilder.defaultClient();
    private static final DynamoDB dynamoDB = new DynamoDB(client);
    private static final String TABLE_NAME = "item";
    private static final Table table = dynamoDB.getTable(TABLE_NAME);

    public static class Input {
        public String pk;
        public String sk;
        public String nome;
        public String status;
    }

    @Override
    public Map<String, Object> handleRequest(Input input, Context context) {
        Map<String, Object> response = new HashMap<>();

        try {
            UpdateItemSpec updateSpec = new UpdateItemSpec()
                    .withPrimaryKey("PK", input.pk, "SK", input.sk)
                    .withUpdateExpression("set nome = :n, #s = :s")
                    .withNameMap(new NameMap().with("#s", "status")) // substitui o nome reservado Status
                    .withValueMap(new ValueMap()
                            .withString(":n", input.nome)
                            .withString(":s", input.status))
                    .withReturnValues("ALL_NEW");

            UpdateItemOutcome outcome = table.updateItem(updateSpec);

            response.put("message", "Item atualizado com sucesso.");
            response.put("updatedItem", outcome.getItem().asMap());
        } catch (Exception e) {
            response.put("erro:", e.getMessage());
        }

        return response;
    }
}

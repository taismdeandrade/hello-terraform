package com.example;

import com.amazonaws.services.dynamodbv2.AmazonDynamoDB;
import com.amazonaws.services.dynamodbv2.AmazonDynamoDBClientBuilder;
import com.amazonaws.services.dynamodbv2.document.DynamoDB;
import com.amazonaws.services.dynamodbv2.document.Table;
import com.amazonaws.services.dynamodbv2.document.spec.DeleteItemSpec;
import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

import java.util.HashMap;
import java.util.Map;

public class DeleteItemHandler implements RequestHandler<DeleteItemHandler.Input, Map<String, Object>> {

    private static final AmazonDynamoDB client = AmazonDynamoDBClientBuilder.defaultClient();
    private static final DynamoDB dynamoDB = new DynamoDB(client);
    private static final String TABLE_NAME = "item";
    private static final Table table = dynamoDB.getTable(TABLE_NAME);

    public static class Input {
        public String pk;
        public String itemId;
    }

    @Override
    public Map<String, Object> handleRequest(Input input, Context context) {Map<String, Object> response = new HashMap<>();

        try {
            String pk = "LIST#" + input.pk;
            String sk = "ITEM#" + input.itemId;

            DeleteItemSpec delete = new DeleteItemSpec().withPrimaryKey("PK", pk, "SK", sk);

            table.deleteItem(delete);

            response.put("message", "Item excluído com sucesso.");
            response.put("PK", pk);
            response.put("SK", sk);
        } catch (Exception e) {
            response.put("erro:", "Erro ao excluir item: " + e.getMessage());
        }

        return response;
    }
}

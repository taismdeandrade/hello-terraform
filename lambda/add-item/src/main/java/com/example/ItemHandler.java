package com.example;

import com.amazonaws.services.dynamodbv2.AmazonDynamoDB;
import com.amazonaws.services.dynamodbv2.AmazonDynamoDBClientBuilder;
import com.amazonaws.services.dynamodbv2.document.DynamoDB;
import com.amazonaws.services.dynamodbv2.document.Item;
import com.amazonaws.services.dynamodbv2.document.Table;
import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

public class ItemHandler implements RequestHandler<ItemHandler.Input, Map<String, Object>> {

    private static final AmazonDynamoDB client = AmazonDynamoDBClientBuilder.defaultClient();
    private static final DynamoDB dynamoDB = new DynamoDB(client);
    private static final String TABLE_NAME = "item";
    private static final Table table = dynamoDB.getTable(TABLE_NAME);

    public static class Input {
        public String name;
        public String date;
    }

    @Override
    public Map<String, Object> handleRequest(Input input, Context context) {
        Map<String, Object> response = new HashMap<>();

        try {
            String nome = input.name;
            String data = input.date;
            String status = "todo";

            String pk = "LIST#" + data.replaceAll("-", "");

            String itemId = "ITEM#" + UUID.randomUUID();

            Item item = new Item()
                    .withPrimaryKey("PK", pk, "SK", itemId)
                    .withString("nome", nome)
                    .withString("data", data)
                    .withString("status", status);

            table.putItem(item);

            response.put("PK", pk);
            response.put("SK", itemId);
            response.put("nome", nome);
            response.put("data", data);
            response.put("status", status);

        } catch (Exception e) {
            response.put("Erro:", e.getMessage());
        }

        return response;
    }
}

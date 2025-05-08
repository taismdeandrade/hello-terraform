package com.example.dynamo.service;

import com.example.dynamo.dto.ItemDto;
import com.example.dynamo.entities.Item;
import io.awspring.cloud.dynamodb.DynamoDbTemplate;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.enhanced.dynamodb.Key;
import software.amazon.awssdk.services.dynamodb.model.AttributeValue;
import software.amazon.awssdk.services.dynamodb.model.DeleteItemRequest;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Map;
import java.util.UUID;

@Service
public class ItemService {

    private final DynamoDbTemplate dynamoDbTemplate;

    public ItemService(DynamoDbTemplate dynamoDbTemplate){
        this.dynamoDbTemplate = dynamoDbTemplate;
    }

    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyyMMdd");

    public Item criarItem(ItemDto itemDto) {
        try {
            Item item = new Item();
            LocalDate dataAtual = LocalDate.now();

            item.setNome(itemDto.nome());
            item.setItemId("ITEM#" + UUID.randomUUID().toString());
            item.setData("LIST#" + dataAtual.format(DATE_FORMATTER));
            item.setStatus("Todo");

            dynamoDbTemplate.save(item);
            return item;
        } catch (Exception e) {
            throw new RuntimeException("Erro ao salvar : " + e.getMessage(), e);
        }
    }

    public ResponseEntity<Void> deletarItem(String pKey, String sKey){
        if (pKey == null || pKey.trim().isEmpty()) {
            throw new IllegalArgumentException("A Partition key é obrigatória");
        }

        if (sKey == null || sKey.trim().isEmpty()) {
            throw new IllegalArgumentException("O ItemId não pode ser vazio");
        }

        Item item = dynamoDbTemplate.load(Key.builder()
                .partitionValue(pKey)
                .sortValue(sKey)
                .build(), Item.class);

        if (item == null){
            return ResponseEntity.notFound().build();
        }

        dynamoDbTemplate.delete(item);
        return ResponseEntity.noContent().build();
    }
}
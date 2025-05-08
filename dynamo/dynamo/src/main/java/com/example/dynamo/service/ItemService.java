package com.example.dynamo.service;

import com.example.dynamo.dto.ItemDto;
import com.example.dynamo.entities.Item;
import io.awspring.cloud.dynamodb.DynamoDbTemplate;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
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
            item.setItemId(UUID.randomUUID());
            item.setData(dataAtual.format(DATE_FORMATTER));
            item.setStatus("Todo");

            dynamoDbTemplate.save(item);
            return item;
        } catch (Exception e) {
            throw new RuntimeException("Erro ao salvar : " + e.getMessage(), e);
        }
    }
}
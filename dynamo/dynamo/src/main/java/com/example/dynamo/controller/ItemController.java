package com.example.dynamo.controller;

import com.example.dynamo.dto.ItemDto;
import com.example.dynamo.entities.Item;
import com.example.dynamo.service.ItemService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/v1/lista")
public class ItemController {


    private final ItemService itemService;

    public ItemController(ItemService itemService) {
        this.itemService = itemService;
    }

    @PostMapping
    public ResponseEntity<Item> criarItem(@RequestBody ItemDto itemDto) {
        Item item = itemService.criarItem(itemDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(item);
    }
}

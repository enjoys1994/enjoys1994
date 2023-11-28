package com.example.drools.demo;

import org.kie.api.KieServices;
import org.kie.api.runtime.KieContainer;
import org.kie.api.runtime.KieSession;

import lombok.Data;

/**
 * @author tianwen.yin
 */
public class HelloDrools {

    public static void main(String[] args) {


        // 初始化
        KieServices kieServices = KieServices.Factory.get();
        KieContainer kieContainer = kieServices.newKieClasspathContainer();
        KieSession kieSession = kieContainer.newKieSession();
        // 构建 fact
        User user = new User();
        user.setName("taven");
        user.setPoint(10D);
        user.setLevel(5);
        user.setPrice(100D);
        user.setAge(19);

        Order order = new Order();
        order.setPrice(58D);
        // insert fact
        kieSession.insert(user);
        kieSession.insert(order);
        // 触发所有规则
        int fireCount = kieSession.fireAllRules();
       // kieSession.fireAllRules(1);
        //System.out.println("fireRuleCount:" + fireCount);
        kieSession.dispose();
    }

    @Data
    public static class Order {
        private Double price;
    }

    @Data
    public static class User {
        private String name;
        private Integer age;
        private Double price;
        private Integer level;
        private Double point;

    }

}
package demo.eval;

import com.cronutils.model.Cron;
import com.cronutils.model.CronType;
import com.cronutils.model.definition.CronDefinition;
import com.cronutils.model.definition.CronDefinitionBuilder;
import com.cronutils.parser.CronParser;

/**
 * app
 *
 * @author wanggy
 * @date 2023/3/13
 */
public class CronUtilTest {

    public static void main(String[] args) {
        CronDefinition cronDefinition = CronDefinitionBuilder.instanceDefinitionFor(CronType.QUARTZ);

        CronParser parser = new CronParser(cronDefinition);
        Cron quartzCron = parser.parse("00 00 * * 1 0");
        System.out.printf("quartzCron");
    }
}

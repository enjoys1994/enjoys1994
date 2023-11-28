package demo.eval;

import org.apache.commons.math3.stat.descriptive.DescriptiveStatistics;

import javax.script.ScriptContext;
import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;
import javax.script.SimpleBindings;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.function.Function;

public class JdkScriptEngine {


    public static void main(String[] args) throws Exception {
        ArrayList<String> strings = new ArrayList<>();
        ArrayList<String> strings2 = new ArrayList<>();
        System.out.println(strings.equals(strings2));


        ScriptEngineManager manager = new ScriptEngineManager();

        ScriptEngine nashorn = manager.getEngineByName("nashorn");

        Double[] data = {1.0, 2.0, 3.0, 4.0, 5.0};
        List<Double> list = Arrays.asList(data);
        SimpleBindings globalBinding = new SimpleBindings();
        globalBinding.put("mean", (Function<List<Double>, Double>) JdkScriptEngine::mean);
        globalBinding.put("variance", (Function<List<Double>, Double>) JdkScriptEngine::variance);
        nashorn.setBindings(globalBinding, ScriptContext.GLOBAL_SCOPE);
        SimpleBindings simpleBinding = new SimpleBindings();

        simpleBinding.put("data",list);
        simpleBinding.put("n", 2);
        Object eval = nashorn.eval("mean(data) + n * variance(data)",simpleBinding);
        System.out.println(eval);
    }



    private static Double variance(List<Double> data) {
        DescriptiveStatistics stats = new DescriptiveStatistics();
        for (double value : data) {
            stats.addValue(value);
        }
        return stats.getMean();
    }

    private static Double mean(List<Double> data) {
        DescriptiveStatistics stats = new DescriptiveStatistics();
        for (double value : data) {
            stats.addValue(value);
        }
        return stats.getVariance();
    }

}

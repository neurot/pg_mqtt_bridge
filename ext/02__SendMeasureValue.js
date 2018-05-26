var Thread = Java.type("java.lang.Thread");

function execute(action) {
    out("Test Script: " + action.getName());
    //for (var i = 0; i < 1000; i++) {
    do {
        send();
        Thread.sleep(1000);
    } while (true)
    action.setExitCode(0);
    action.setResultText("done.");
    out("Test Script: Done");
    return action;
}

function send() {
    mqttManager.publish("dataservice/input", "{\"timestamp\": \"2018-05-25 22:35:50.436664\",\"input_id\": \"bfcb9574-55f3-11e8-8474-b8f6b115ae49\",\"measure_value\": 22222.22}");
}

function out(message){
    output.print(message);
}

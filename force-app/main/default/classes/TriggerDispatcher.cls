/**
 * @description  This class runs the appropriate methods on the trigger handler based on the current trigger context.
 * @author Kostiantyn Murin
 * @date 18-06-2023
 */
public class TriggerDispatcher {
    /**
     * @description  Call this method from your trigger, passing in an instance of a trigger handler which implements ITriggerHandler.
     *               This method will fire the appropriate methods on the handler depending on the trigger context.
     * @author Kostiantyn Murin
     * @date 18-06-2023
     * @param handler ITriggerHandler
     * @param triggerEvent System.TriggerOperation
     */
    public static void run(ITriggerHandler handler, System.TriggerOperation triggerEvent) {
    
        // Detect the current trigger context and fire the relevant methods on the trigger handler:
        switch on triggerEvent {
            when BEFORE_INSERT {
                handler.beforeInsert(Trigger.new);
            } when BEFORE_UPDATE {
                handler.beforeUpdate(Trigger.newMap, Trigger.oldMap);
            } when BEFORE_DELETE {
                handler.beforeDelete(Trigger.oldMap);
            } when AFTER_INSERT {
                handler.afterInsert(Trigger.newMap);
            } when AFTER_UPDATE {
                handler.afterUpdate(Trigger.newMap, Trigger.oldMap);
            } when AFTER_DELETE {
                handler.afterDelete(Trigger.oldMap);
            } when AFTER_UNDELETE {
                handler.afterUndelete(Trigger.oldMap);
            }
        }  
    }
}
  
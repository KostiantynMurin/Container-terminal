public class TriggerDispatcher {
    public static void run(TriggerHandlerInterface handler, System.TriggerOperation triggerEvent)
    {
      switch on triggerEvent {
        when BEFORE_INSERT {
          handler.beforeInsert(trigger.new);
        } when BEFORE_UPDATE {
          handler.beforeUpdate(trigger.newMap, trigger.oldMap);
        } when BEFORE_DELETE {
          handler.beforeDelete(trigger.oldMap);
        } when AFTER_INSERT {
          handler.afterInsert(Trigger.newMap);
        } when AFTER_UPDATE {
          handler.afterUpdate(trigger.newMap, trigger.oldMap);
        } when AFTER_DELETE {
          handler.afterDelete(trigger.oldMap);
        } when AFTER_UNDELETE {
          handler.afterUndelete(trigger.oldMap);
        }
      }  
    }
  }
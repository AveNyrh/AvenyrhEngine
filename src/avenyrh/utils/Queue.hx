package avenyrh.utils;

/**
 * Fifo list
 */
class Queue<T> 
{
    var array : Array<T>;

    public var length (get, null) : Int;
    
    public function new() 
    {
        array = [];    
    }

    /**
     * Adds an item to the end of the queue
     */
    public inline function enqueue(item : T)
    {
        array.insert(0, item);
    }

    /**
     * Returns the item on top of the queue
     */
    public inline function dequeue() : T
    {
        return array.pop();
    }

    /**
     * Returns the item on top of the queue without removing it from the queue
     */
    public inline function peek() : T
    {
        return array[array.length - 1];
    }

    function get_length() : Int
    {
        return array.length;
    }
}
/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */
package org.tinytlf.layout.model.factories
{
    import flash.display.Shape;
    import flash.events.EventDispatcher;
    import flash.text.engine.ContentElement;
    import flash.text.engine.ElementFormat;
    import flash.text.engine.GraphicElement;
    import flash.text.engine.GroupElement;
    import flash.text.engine.TextElement;
    
    import org.tinytlf.ITextEngine;
    
    public class ContentElementFactory implements IContentElementFactory
    {
        public function execute(data:Object, ... context:Array):ContentElement
        {
            var element:ContentElement;
            
            var name:String = "";
            
            if(context.length)
                name = context[context.length - 1].localName();
            
            //If the data is an empty string, insert a placeholder GraphicElement.
            if(data is String && data === "")
                element = new GraphicElement(new Shape(), 1, 1, getElementFormat(context), getEventMirror(name));
            else if(data is String)
                element = new TextElement(String(data), getElementFormat(context), getEventMirror(name));
            else if(data is Vector.<ContentElement>)
                element = new GroupElement(Vector.<ContentElement>(data), getElementFormat(context));
            
            if(!element)
                return null;
            
            if(!(element is GroupElement))
            {
                //Do any decorations for this element
                var dec:Object = engine.styler.describeElement(context.length ? context : null);
                if(dec != null)
                    engine.decor.decorate(element, dec, 'layer' in dec ? int(dec['layer']) : 2);
            }

            element.userData = context;
            
            return element;
        }
        
        private var _engine:ITextEngine;
        
        public function get engine():ITextEngine
        {
            return _engine;
        }
        
        public function set engine(textEngine:ITextEngine):void
        {
            if(textEngine === _engine)
                return;
            
            _engine = textEngine;
        }
        
        protected function getElementFormat(context:Object):ElementFormat
        {
            // You can't render a textLine with a null ElementFormat, so return an empty one here.
            if(!_engine)
                return new ElementFormat();
            
            return engine.styler.getElementFormat(context);
        }
        
        protected function getEventMirror(forName:String):EventDispatcher
        {
            if(!_engine)
                return null;
            
            return engine.interactor.getMirror(forName);
        }
    }
}

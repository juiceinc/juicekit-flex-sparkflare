package sparkflare.layouts
{
    import mx.collections.ArrayCollection;
    
    import org.juicekit.animate.Transitioner;
    import org.juicekit.util.Property;
    
    import sparkflare.mappers.MapperBase;
    
    /**
     * Layouts are IMappers that affect multiple properties at once, typically
     * x, y, height, and width. HorizontalStripeLayout lays items out in vertical
     * stripes.
     */
    [Bindable]
    public class TileLayout extends MapperBase
    {
        
        public var itemHeight:Number = 22;
        public var horizontalGap:Number = 0; 
        public var verticalGap:Number = 0; 
        
        /**
         * Lay the elements out in horizontal rows
         * or vertical columns
         */
        public var direction:String = 'horizontal';
        
        
        /** @inheritDoc */
        override public function operate(items:ArrayCollection, t:Transitioner = null, visualElementProperty:String=null):void 
        {
            var row:Object;
            var _t:Transitioner;
            
            if (enabled) 
            {
                var ownerWidth:Number = NaN;
                var ownerHeight:Number = NaN;
                _t = (t != null ? t : Transitioner.DEFAULT);
                                
                var visualElementProp:Property;
                if (visualElementProperty) 
                    visualElementProp = Property.$(visualElementProperty)

                if (items) 
                {
                    var y:Number = 0;
                    var x:Number = 0;
                    var h:Number = 0;
                    var w:Number = 0;
                    var maxHeight:Number = Number.NEGATIVE_INFINITY;
                    var maxWidth:Number = Number.NEGATIVE_INFINITY;
                    for each (row in items) 
                    {
                        if (isNaN(ownerWidth)) {
                            if (visualElementProp) {
                                row = visualElementProp.getValue(row);
                            }
                            ownerHeight = row.owner.height;
                            ownerWidth = row.owner.width;
                        }
                        h = row.height;
                        w = row.width;
                        
                        if (direction == 'horizontal') 
                        {
                            if ((x + w) <= ownerWidth)
                            {
                                _t.setValue(row, 'y', y);
                                _t.setValue(row, 'x', x);
                                maxHeight = h > maxHeight ? h : maxHeight;
                                x += (w + horizontalGap);
                            }
                            else 
                            {
                                // start a new row    
                                x = 0;
                                y += (maxHeight + verticalGap);
                                maxHeight = Number.NEGATIVE_INFINITY;
                                maxWidth = Number.NEGATIVE_INFINITY;
                                _t.setValue(row, 'y', y);
                                _t.setValue(row, 'x', x);
								x += (w + horizontalGap);
                            }
                        }
                        else 
                        {
                            if ((y + h) <= ownerHeight)
                            {
                                _t.setValue(row, 'y', y);
                                _t.setValue(row, 'x', x);
                                maxWidth = w > maxWidth ? w : maxWidth;
                                y += (h + verticalGap);
                            }
                            else 
                            {
                                // start a new row    
                                y = 0;
                                x += (maxWidth + horizontalGap);
                                maxHeight = Number.NEGATIVE_INFINITY;
                                maxWidth = Number.NEGATIVE_INFINITY;
                                _t.setValue(row, 'y', y);
                                _t.setValue(row, 'x', x);
								y += (h + verticalGap);
                            }                        
                        }

                    }
                }
                
                _t = null;
            }
        }
        
        
        /**
         * Constructor
         */
        public function TileLayout()
        {
        }
        
        
    }
}
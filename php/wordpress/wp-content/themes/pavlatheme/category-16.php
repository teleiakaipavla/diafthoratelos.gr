<?php
get_header();
?>


<script>

    function SelectType(type) {
        $('img[data-type="' + type + '"]').show();

        if (type == 'bad')
            $('img[data-type="good"]').hide()

        if (type == 'good')
            $('img[data-type="bad"]').hide()

        if (type == '') {
            $('img[data-type="good"]').hide()
            $('img[data-type="bad"]').hide()
        }
    }
</script>



    <div class="content">
        <h1 class="exeisimvikaisemena-icon"><?php echo single_cat_title( $category_id ); ?></h1>
        <div class="subtext"><?php echo category_description( $category_id );  ?></div>
        <div class="text exeisimvikaisemena">
           <div class="left diafthora" ><img src="images/exeisimvikaisemena/diafthora.png" onclick="SelectType('bad')" onmouseover="SelectType('bad')"  />
               <img src="images/exeisimvikaisemena/tick.png" class="tick" data-type="bad" />
           </div>
           <div class="left or" ><img src="images/exeisimvikaisemena/or.png" /></div>
           <div class="left peristatiko"><img src="images/exeisimvikaisemena/peristatiko.png" onclick="SelectType('good')" onmouseover="SelectType('good')"  />
           <img src="images/exeisimvikaisemena/tick.png" class="tick" data-type="good" />
           </div>
            
           <div class="clear"></div>
           <div  class="left next-left"><a href="?cat=18"><img border="0" src="images/btns/next.png" data-type="bad" /></a></div>
           <div class="left next-right"><a href="?cat=19"><img border="0" src="images/btns/next.png" data-type="good" /></a></div>
           <div class="clear"></div>
            
        </div>
        <div class="readmore">
            <div class="starts">* * *</div>
            <div class="txt">ΤΑ ΣΤΟΙΧΕΙΑ ΥΠΟΒΑΛΛΟΝΤΑΙ ΑΝΩΝΥΜΑ</div>
            <div class="starts">* * *</div>
            <div class="link"><a href="#">Μάθε περισσότερα</a></div>
        </div>
    </div>

<?php
get_footer();
?>

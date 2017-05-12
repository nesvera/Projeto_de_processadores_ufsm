/*
* @(#)Canvas_Gif.java  1.0  30/03/2001
*	
* Aline Vieira de Mello
* Pontif�cia Universidade Cat�lica do Rio Grande do Sul - Faculdade de Inform�tica
*/

import java.awt.*;

/**
* <i>Canvas_Gif</i> implementa o canvas que cont�m a figura Gaph.gif.
*/
public class Canvas_Gif extends Canvas
{
	private Image imagem;
	private int img_indice;
	
	public Canvas_Gif()
	{
		super();
	}

	/**
	* Repinta a �rea do canvas.
	*/
	public void paint(Graphics g)
	{
		imagem=getToolkit().getDefaultToolkit().getImage("gaph.gif");
    g.drawImage(imagem,0,0,this);
	}
	
	/**
	* Reescrita o m�todo update para tornar a pintura da tela mais veloz.
	*/
	public void update(Graphics g)
	{
		paint(g);
	}
}
/*
* @(#)Flag.java  1.0  30/03/2001
*	
* Aline Vieira de Mello
* Pontif�cia Universidade Cat�lica do Rio Grande do Sul - Faculdade de Inform�tica
*/

import javax.swing.*;

/**
* <i>Flag</i> implementa Flag adicionando na posi��o indicada do JPanel.
*/
public class Flag
{
	private	JCheckBox	cflag;
	private String 		nome;
	
	public Flag(JPanel panel,String nome,int x,int y,int dimx,int dimy,String msg)
	{
		this.nome=nome;
		cflag=new JCheckBox(nome,false);	
		cflag.setBounds(x,y,dimx,dimy);
		cflag.setEnabled(false);
		cflag.setToolTipText(msg);
		panel.add(cflag);
	}	
	
	/**
	* Captura o nome atribu�do ao flag.
	*/
	public String getNome(){return nome;}
	
	/**
	* Captura o valor booleano atribu�do ao flag.
	*/
	public boolean getValFlag(){return cflag.isSelected();} 
	
	/**
	* Atribui o valor booleano ao flag.
	*/
	public void setValFlag(boolean b){cflag.setSelected(b);}
}
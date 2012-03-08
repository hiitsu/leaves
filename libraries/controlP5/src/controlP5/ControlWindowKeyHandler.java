package controlP5;

/**
 * controlP5 is a processing gui library.
 *
 *  2006-2012 by Andreas Schlegel
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public License
 * as published by the Free Software Foundation; either version 2.1
 * of the License, or (at your option) any later version.
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General
 * Public License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place, Suite 330,
 * Boston, MA 02111-1307 USA
 *
 * @author 		Andreas Schlegel (http://www.sojamo.de)
 * @modified	02/29/2012
 * @version		0.7.1
 *
 */

import java.awt.event.KeyEvent;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

/**
 * Handles key events.
 * 
 * @exclude
 */
public class ControlWindowKeyHandler implements ControlP5Constants {

	private ControlWindow _myMasterControlWindow;

	public boolean isShiftDown = false;

	public boolean isKeyDown = false;

	public boolean isAltDown = false;

	public boolean isKeyMenu = false;

	public boolean isCommandDown = false;

	protected char key = ' ';

	protected int keyCode = -1;

	Map<KeyCode, ControlKey> keymap = new HashMap<KeyCode, ControlKey>();

	public ControlWindowKeyHandler(ControlP5 theControlP5) {
		_myMasterControlWindow = theControlP5.controlWindow;
	}

	public void update(ControlWindow theControlWindow) {
		_myMasterControlWindow = theControlWindow;
	}

	public void keyEvent(final KeyEvent theKeyEvent, final ControlWindow theControlWindow, final boolean isMasterWindow) {

		List<Integer> keys = new LinkedList<Integer>();

		if (theKeyEvent.getID() == KeyEvent.KEY_PRESSED) {
			switch (theKeyEvent.getKeyCode()) {
			case (KeyEvent.VK_SHIFT):
				isShiftDown = true;
				break;
			case (KeyEvent.VK_ALT):
				isAltDown = true;
				break;
			case (157):
				isCommandDown = true;
				break;
			}
			key = theKeyEvent.getKeyChar();
			keyCode = theKeyEvent.getKeyCode();
			isKeyDown = true;
		}
		if (theKeyEvent.getID() == KeyEvent.KEY_RELEASED) {
			switch (theKeyEvent.getKeyCode()) {
			case (KeyEvent.VK_SHIFT):
				isShiftDown = false;
				break;
			case (KeyEvent.VK_ALT):
				isAltDown = false;
				break;
			case (157):
				isCommandDown = false;
				break;
			}
			isKeyDown = false;
		}

		if (theKeyEvent.getID() == KeyEvent.KEY_PRESSED) {
			if (isAltDown) {
				if (theKeyEvent.getKeyCode() == KEYCONTROL) {
					isKeyMenu = !isKeyMenu;
					// _myMasterControlWindow.keyMenu(isKeyMenu);
				}
			}
		}
		if (theKeyEvent.getID() == KeyEvent.KEY_PRESSED && isAltDown && _myMasterControlWindow.controlP5.isShortcuts) {
			if (isKeyMenu) {
				handleInputEvent(theKeyEvent.getKeyCode());
			}
			if (theKeyEvent.getKeyCode() == SAVE) {
				if (isShiftDown) {
					_myMasterControlWindow.controlP5.saveProperties(); // save properties
				}
			}
			if (theKeyEvent.getKeyCode() == LOAD) {
				if (isShiftDown) {
					_myMasterControlWindow.controlP5.loadProperties(); // load properties
				}
			}
			if (theKeyEvent.getKeyCode() == HIDE) {
				if (_myMasterControlWindow.isVisible) {
					_myMasterControlWindow.controlP5.hide();
				} else {
					_myMasterControlWindow.controlP5.show();
				}
			}
		}

		keys.add(new Integer(key));
		if (isShiftDown)
			keys.add(new Integer(KeyEvent.VK_SHIFT));
		if (isAltDown)
			keys.add(new Integer(KeyEvent.VK_ALT));
		if (isCommandDown)
			keys.add(new Integer(157));

		if (theKeyEvent.getID() == KeyEvent.KEY_PRESSED) {
			KeyCode code = new KeyCode(keys);
			if (keymap.containsKey(code)) {
				keymap.get(code).keyEvent();
			}
		}
		/*
		 * during re/loading period of settings theControlWindow might be null
		 */
		if (theControlWindow != null) {
			theControlWindow.keyEvent(theKeyEvent);
		}
	}

	/**
	 * @param theKey char
	 */
	protected void handleInputEvent(int theKeyCode) {
		switch (theKeyCode) {
		case (SWITCH_FORE):
		case (SWITCH_BACK):
		case (PRINT):
		case (DECREASE):
		case (INCREASE):
		case (RESET):
			ControlP5.logger().warning("Key controls are not supported in this version anymore.");
		}
	}

	public void reset() {
		isShiftDown = false;
		isKeyDown = false;
		isAltDown = false;
		isKeyMenu = false;
		isCommandDown = false;
	}

	public void mapKey(ControlKey theKey, int... theChar) {
		keymap.put(new KeyCode(theChar), theKey);
	}

	class KeyCode {

		List<Integer> chars;

		KeyCode(List<Integer> theChars) {
			chars = new LinkedList<Integer>(theChars);
		}

		KeyCode(int... theChars) {
			chars = new LinkedList<Integer>();
			for (int i : theChars) {
				chars.add(i);
			}
		}

		KeyCode(char... theChars) {
			chars = new LinkedList<Integer>();
			for (int i : theChars) {
				chars.add(i);
			}
		}

		public int size() {
			return chars.size();
		}

		public List<Integer> getChars() {
			return chars;
		}

		public boolean equals(Object obj) {
			if (!(obj instanceof KeyCode)) {
				return false;
			}

			KeyCode k = (KeyCode) obj;

			if (k.size() != size()) {
				return false;
			}

			for (int c : k.getChars()) {
				if (!contains(c)) {
					return false;
				}
			}
			return true;
		}

		boolean contains(int n) {
			for (int c : chars) {
				if (n == c) {
					return true;
				}
			}
			return false;
		}

		public int hashCode() {
			int hashCode = 0;
			for (int c : chars) {
				hashCode += c;
			}
			return hashCode;
		}
	}

}
